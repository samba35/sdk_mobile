package com.example.sdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.ablecredit.sdk.manager.SdkManager
import com.ablecredit.sdk.model.LoanRequest
import com.ablecredit.sdk.model.LoanResponse
import com.ablecredit.sdk.model.BusinessProfile
import com.ablecredit.sdk.model.LoanData
import com.ablecredit.sdk.model.BorrowerDetails
import com.ablecredit.sdk.manager.SdkConfig 
//import com.ablecredit.sdk.manager.UploadStatusListener
import com.ablecredit.sdk.model.FileStatus
import com.ablecredit.sdk.recorder.interfaces.UploadStatusListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class AbleCreditPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private var activity: Activity? = null
    private val tag = "AbleCreditPlugin"

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "ablecredit_sdk")
        channel.setMethodCallHandler(this)
        applicationContext = binding.applicationContext
        Log.d(tag, "AbleCreditPlugin attached to engine")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        applicationContext = null
        Log.d(tag, "AbleCreditPlugin detached from engine")
    }

    // ActivityAware methods
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(tag, "Activity attached: $activity")
    }

    override fun onDetachedFromActivity() {
        activity = null
        Log.d(tag, "Activity detached")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(tag, "Activity re-attached: $activity")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        Log.d(tag, "Activity detached on config change")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val currentContext = activity ?: applicationContext
        if (currentContext == null) {
            result.error("NO_CONTEXT", "Cannot execute method. No context available.", null)
            return
        }

        when (call.method) {
            "initialize" -> handleInitialize(call, result, currentContext)
            "createNewLoan" -> handleCreateNewLoan(call, result, currentContext)
            "getSdkConfig" -> handleGetSdkConfig(result)
            "recordAudio" -> handleRecordAudio(call, result, currentContext)
            "captureFamilyPhotos" -> handleCaptureFamilyPhotos(call, result, currentContext)
            "captureBusinessPhotos" -> handleCaptureBusinessPhotos(call, result, currentContext)
            "captureCollateralPhotos" -> handleCaptureCollateralPhotos(call, result, currentContext)
            "clear" -> handleClear(result, currentContext)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result, context: Context) {
        val apiKey = call.argument<String>("apiKey")
        val tenantId = call.argument<String>("tenantId")
        val userId = call.argument<String>("userId")
        val baseUrl = call.argument<String>("baseUrl")

        if (apiKey.isNullOrBlank() || tenantId.isNullOrBlank() || userId.isNullOrBlank() || baseUrl.isNullOrBlank()) {
            result.error("INVALID_ARGS", "apiKey, tenantId, userId, and baseUrl must not be empty.", null)
            return
        }

        Log.d(tag, "Initializing SDK with apiKey: $apiKey")
        SdkManager.initialize(context, apiKey, tenantId, userId, baseUrl) {status, message ->
            // Ensure the result is sent on the main thread, as Flutter requires it.
            activity?.runOnUiThread {
                val response = mapOf("status" to status, "message" to message)
                if (status == 1) {
                    Log.d(tag, "Initialization success: $message")
                    result.success(response)
                } else {
                    Log.e(tag, "Initialization failed: $message")
                    result.error("INIT_FAILED", message, response)
                }
            }
        }
    }

    private fun handleCreateNewLoan(call: MethodCall, result: Result, context: Context) {
        val payload = call.argument<Map<String, Any>>("loanRequest")
        if (payload == null) {
            result.error("INVALID_ARGS", "loanRequest payload is required.", null)
            return
        }

        try {
            // Parse BusinessProfile
            val businessProfileMap = payload["business_profile"] as? Map<String, String>
            val businessProfile = if (businessProfileMap != null) {
                BusinessProfile(
                    product = businessProfileMap["product"] ?: "",
                    business_model = businessProfileMap["business_model"] ?: "",
                    industry = businessProfileMap["industry"] ?: ""
                )
            } else {
                result.error("INVALID_ARGS", "business_profile is missing or malformed.", null)
                return
            }

            // Parse BorrowerDetails
            val borrowerDetailsMap = (payload["data"] as? Map<String, Any>)?.get("borrower_details") as? Map<String, String>
            val borrowerDetails = if (borrowerDetailsMap != null) {
                BorrowerDetails(
                    entity_type = borrowerDetailsMap["entity_type"] ?: "",
                    name = borrowerDetailsMap["name"] ?: "",
                    dob = borrowerDetailsMap["dob"] ?: "",
                    mobile = borrowerDetailsMap["mobile"] ?: ""
                )
            } else {
                result.error("INVALID_ARGS", "data.borrower_details is missing or malformed.", null)
                return
            }

            // Parse LoanData
            val loanData = LoanData(
                borrower_details = borrowerDetails
            )

            // Construct LoanRequest
            val loanRequest = LoanRequest(
                loan_reference = payload["loan_reference"] as? String ?: "",
                client_unique_id = payload["client_unique_id"] as? String ?: "",
                product_id = payload["product_id"] as? String ?: "",
                branch_id = payload["branch_id"] as? String ?: "",
                source_system = payload["source_system"] as? String ?: "",
                business_profile = businessProfile,
                data = loanData
            )

            Log.d(tag, "Creating new loan case with payload: $loanRequest")
            SdkManager.createNewLoanCase(context, loanRequest) { loanResponse ->
                activity?.runOnUiThread {
                    if (loanResponse?.data?.application?._id != null) {
                        val applicationId = loanResponse.data.application._id
                        val responseMap = mapOf(
                            "applicationId" to applicationId,
                            "message" to "Loan created successfully"
                        )
                        Log.d(tag, "Loan creation success: $applicationId")
                        result.success(responseMap)
                    } else {
                        Log.e(tag, "Loan creation failed.")
                        result.error("CREATION_FAILED", "SDK returned a null or invalid response.", null)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(tag, "Error creating LoanRequest or calling SDK", e)
            result.error("PAYLOAD_ERROR", "Failed to process loan request payload: ${e.message}", null)
        }
    }



    private fun handleGetSdkConfig(result: Result) {
        Log.d(tag, "Getting SDK config.")
        val sdkConfig = SdkManager.getSdkConfig()
        val configMap = mapOf(
            "apiKey" to sdkConfig.apiKey,
            "tenantId" to sdkConfig.tenantId,
            "userId" to sdkConfig.userId,
            "baseUrl" to sdkConfig.baseUrl
        )
        result.success(configMap)
    }

    private fun handleRecordAudio(call: MethodCall, result: Result, context: Context) {
        val loanApplicationId = call.argument<String>("loanApplicationId")
        if (loanApplicationId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "loanApplicationId must not be empty.", null)
            return
        }
        Log.d(tag, "Recording audio for loan ID: $loanApplicationId")
        val intentContext = activity ?: context

        // val uploadListener = object : UploadStatusListener {
        //     override fun onStatusChanged(uniqueId: String, status: FileStatus, message: String?) {
        //         Log.d(tag, "Audio upload status changed for $uniqueId: Status=${status.name}, Message=$message")
        //     }
        // }

        SdkManager.recordAudio(intentContext, loanApplicationId)
        result.success(null)
    }

    private fun handleCaptureFamilyPhotos(call: MethodCall, result: Result, context: Context) {
        val loanApplicationId = call.argument<String>("loanApplicationId")
        if (loanApplicationId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "loanApplicationId must not be empty.", null)
            return
        }
        Log.d(tag, "Capturing family photos for loan ID: $loanApplicationId")
        val intentContext = activity ?: context
        SdkManager.captureFamilyPhotos(intentContext, loanApplicationId)
        result.success(null)
    }

    private fun handleCaptureBusinessPhotos(call: MethodCall, result: Result, context: Context) {
        val loanApplicationId = call.argument<String>("loanApplicationId")
        if (loanApplicationId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "loanApplicationId must not be empty.", null)
            return
        }
        Log.d(tag, "Capturing business photos for loan ID: $loanApplicationId")
        val intentContext = activity ?: context
        SdkManager.captureBusinessPhotos(intentContext, loanApplicationId)
        result.success(null)
    }

    private fun handleCaptureCollateralPhotos(call: MethodCall, result: Result, context: Context) {
        val loanApplicationId = call.argument<String>("loanApplicationId")
        if (loanApplicationId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "loanApplicationId must not be empty.", null)
            return
        }
        Log.d(tag, "Capturing collateral photos for loan ID: $loanApplicationId")
        val intentContext = activity ?: context
        SdkManager.captureCollateralPhotos(intentContext, loanApplicationId)
        result.success(null)
    }

    private fun handleClear(result: Result, context: Context) {
        Log.d(tag, "Clearing SDK configuration.")
        SdkManager.clear(context)
        result.success(null)
    }
}
