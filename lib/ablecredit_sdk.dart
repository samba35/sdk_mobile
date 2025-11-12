import 'package:flutter/services.dart';

class AbleCreditSdk {
  static const MethodChannel _channel = MethodChannel('ablecredit_sdk');

  /// Initializes the AbleCredit SDK.
  /// Must be called before any other SDK methods.
  ///
  /// Returns a map with 'status' (1 for success, 0 for failure) and a 'message'.
  static Future<Map<dynamic, dynamic>> initialize({
    required String apiKey,
    required String tenantId,
    required String userId,
  }) async {
    final result = await _channel.invokeMethod('initialize', {
      'apiKey': apiKey,
      'tenantId': tenantId,
      'userId': userId,
    });
    return result as Map<dynamic, dynamic>;
  }

  /// Creates a new loan application case.
  ///
  /// The [loanRequest] map should contain all necessary data.
  /// Example payload:
  /// ```
  /// {
  ///   "loan_reference": "LN-REF-20251017-0008",
  ///   "client_unique_id": "CUST-20251017-1234",
  ///   "product_id": "MUT-IND-3065",
  ///   "branch_id": "ML1348",
  ///   "source_system": "hotfoot",
  ///   "business_profile": {
  ///     "product": "LAP",
  ///     "business_model": "Trading",
  ///     "industry": "Fashion Apparel"
  ///   },
  ///   "data": {
  ///     "borrower_details": {
  ///       "entity_type": "individual",
  ///       "name": "Shwetanka Srivastava",
  ///       "dob": "24/01/1988",
  ///       "mobile": "8197837043"
  ///     }
  ///   }
  /// }
  /// ```
  /// Returns a map representing the loan response from the SDK on success.
  static Future<Map<dynamic, dynamic>?> createNewLoan({
    required Map<String, dynamic> loanRequest,
  }) async {
    final result = await _channel.invokeMethod('createNewLoan', {
      'loanRequest': loanRequest,
    });
    return result as Map<dynamic, dynamic>?;
  }



  /// Records audio for a given loan application.
  static Future<void> recordAudio({
    required String loanApplicationId,
  }) async {
    await _channel.invokeMethod('recordAudio', {
      'loanApplicationId': loanApplicationId,
    });
  }

  static Future<void> captureFamilyPhotos({
    required String loanApplicationId,
  }) async {
    await _channel.invokeMethod('captureFamilyPhotos', {
      'loanApplicationId': loanApplicationId,
    });
  }

  /// Captures business photos for a given loan application.
  static Future<void> captureBusinessPhotos({
    required String loanApplicationId,
  }) async {
    await _channel.invokeMethod('captureBusinessPhotos', {
      'loanApplicationId': loanApplicationId,
    });
  }

  /// Captures collateral photos for a given loan application.
  static Future<void> captureCollateralPhotos({
    required String loanApplicationId,
  }) async {
    await _channel.invokeMethod('captureCollateralPhotos', {
      'loanApplicationId': loanApplicationId,
    });
  }

  /// Retrieves the current SDK configuration.
  /// Returns a map with apiKey, tenantId, userId, and baseUrl.
  static Future<Map<dynamic, dynamic>?> getSdkConfig() async {
    final result = await _channel.invokeMethod('getSdkConfig');
    return result as Map<dynamic, dynamic>?;
  }

  /// Clears all SDK configuration and resets initialization state.
  static Future<void> clear() async {
    await _channel.invokeMethod('clear');
  }
}
