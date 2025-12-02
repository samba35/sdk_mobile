import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk/ablecredit_sdk.dart';
import 'package:sdk/models/loan_model.dart';
import 'package:sdk/screens/home_screen.dart';
import 'package:sdk/screens/loans_list_screen.dart';
import 'package:sdk/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbleCredit SDK Demo',
      theme: AppTheme.lightTheme,
      home: const MainContainer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  bool _isInitialized = false;
  final List<LoanModel> _loans = [];
  bool _isLoading = false;

  // --- SDK Actions ---

  Future<void> _initializeSdk() async {
    if (_isInitialized) return;

    setState(() => _isLoading = true);
    try {
      final result = await AbleCreditSdk.initialize(
        apiKey: "c61352cc-8030-483c-a6bf-c8abea905d49",
        tenantId: "MUTHOOT-49211173",
        userId: "shwe@gml.co",
      );

      if (result['status'] == 1) {
        setState(() => _isInitialized = true);
        _showSnackBar('SDK Initialized Successfully');
      } else {
        _showSnackBar(
          'SDK Initialization Failed: ${result['message']}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Error initializing SDK: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createLoan() async {
    if (!_isInitialized) {
      await _initializeSdk();
      if (!_isInitialized) return;
    }

    setState(() => _isLoading = true);

    // Hardcoded demo payload
    final loanRequest = {
      "loan_reference": "LN-REF-${DateTime.now().millisecondsSinceEpoch}",
      "client_unique_id": "CUST-${DateTime.now().millisecondsSinceEpoch}",
      "product_id": "MUT-IND-3065",
      "branch_id": "ML1348",
      "source_system": "hotfoot",
      "business_profile": {
        "product": "LAP",
        "business_model": "Trading",
        "industry": "Fashion Apparel",
      },
      "data": {
        "borrower_details": {
          "state_name": "karnataka",
          "entity_type": "individual",
          "name": "Demo User",
          "dob": "24/01/1988",
          "mobile": "8197837043",
          "owner_of_business": "Yes",
        },
        "co_borrower_details": [
          {
            "entity_type": "individual",
            "name": "Co-Borrower",
            "dob": "24/01/1988",
            "relation": "Brother",
            "occupation": "IT Professional",
            "owner_of_business": "No",
          },
        ],
        "employment_details": {
          "employer_name": "optimus",
          "employer_contact_number": "9873654210",
          "doj": "14/10/2020",
          "nature_of_employment": "Full-Time",
          "total_experience": "36",
          "working_location": "#23, Bangalore",
          "working_days_in_month": "28",
          "per_day_earnings": "500",
          "per_month_earnings": "30000",
        },
        "loan_details": {
          "business_name": "trends",
          "quantum": "500000",
          "tenure": "24",
        },
      },
    };

    try {
      final result = await AbleCreditSdk.createNewLoan(
        loanRequest: loanRequest,
      );
      if (result != null) {
        final newLoan = LoanModel(
          id: result['applicationId'] ?? 'UNKNOWN',
          reference: loanRequest['loan_reference'] as String,
          clientName: (loanRequest['data'] as Map)['borrower_details']['name'],
          amount: (loanRequest['data'] as Map)['loan_details']['quantum'],
          status: 'Created',
          createdAt: DateTime.now(),
        );

        setState(() {
          _loans.add(newLoan);
        });

        _showSnackBar('Loan Created Successfully!');
      } else {
        _showSnackBar('Failed to create loan', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error creating loan: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearSdk() async {
    setState(() => _isLoading = true);
    try {
      await AbleCreditSdk.clear();
      setState(() {
        _isInitialized = false;
        _loans.clear();
      });
      _showSnackBar('SDK Cleared');
    } catch (e) {
      _showSnackBar('Error clearing SDK: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        _showSnackBar('Camera permission is required', isError: true);
        return false;
      }
    }

    final audioStatus = await Permission.microphone.status;
    if (!audioStatus.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        _showSnackBar('Microphone permission is required', isError: true);
        return false;
      }
    }

    return true;
  }

  Future<void> _recordAudio(LoanModel loan) async {
    if (!await _checkPermissions()) return;
    try {
      await AbleCreditSdk.recordAudio(loanApplicationId: loan.id);
    } catch (e) {
      _showSnackBar('Error recording audio: $e', isError: true);
    }
  }

  Future<void> _captureFamilyPhotos(LoanModel loan) async {
    if (!await _checkPermissions()) return;
    try {
      await AbleCreditSdk.captureFamilyPhotos(loanApplicationId: loan.id);
    } catch (e) {
      _showSnackBar('Error capturing family photos: $e', isError: true);
    }
  }

  Future<void> _captureBusinessPhotos(LoanModel loan) async {
    if (!await _checkPermissions()) return;
    try {
      await AbleCreditSdk.captureBusinessPhotos(loanApplicationId: loan.id);
    } catch (e) {
      _showSnackBar('Error capturing business photos: $e', isError: true);
    }
  }

  Future<void> _captureCollateralPhotos(LoanModel loan) async {
    if (!await _checkPermissions()) return;
    try {
      await AbleCreditSdk.captureCollateralPhotos(loanApplicationId: loan.id);
    } catch (e) {
      _showSnackBar('Error capturing collateral photos: $e', isError: true);
    }
  }

  Future<void> _generateReport(LoanModel loan) async {
    try {
      await AbleCreditSdk.generateReport(loanApplicationId: loan.id);
      _showSnackBar('Report generation triggered');
    } catch (e) {
      print('Error generating report: $e');
      _showSnackBar('Error generating report: $e', isError: true);
    }
  }

  // --- Navigation ---

  void _navigateToViewLoans() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoansListScreen(
          loans: _loans,
          onRecordAudio: _recordAudio,
          onCaptureFamilyPhotos: _captureFamilyPhotos,
          onCaptureBusinessPhotos: _captureBusinessPhotos,
          onCaptureCollateralPhotos: _captureCollateralPhotos,
          onGenerateReport: _generateReport,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HomeScreen(
          onCreateLoan: _createLoan,
          onViewLoans: _navigateToViewLoans,
          onClearSdk: _clearSdk,
          isSdkInitialized: _isInitialized,
          loanCount: _loans.length,
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
