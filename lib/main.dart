import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer'; // For log
import 'package:permission_handler/permission_handler.dart';
import 'ablecredit_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbleCredit SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'AbleCredit SDK Integration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'App loaded. Please initialize the SDK.';
  bool _isInitialized = false;
  String? _lastLoanId;

  // --- SDK Method Handlers ---

  Future<void> _initializeSdk() async {
    setState(() => _status = 'Initializing...');
    try {
      final result = await AbleCreditSdk.initialize(
        apiKey: "c61352cc-8030-483c-a6bf-c8abea905d49",
        tenantId: "MUTHOOT-49211173", 
        userId: "shwe@gml.co",
      );

      final int status = result['status'];
      final String message = result['message'];

      if (status == 1) {
        setState(() {
          _isInitialized = true;
          _status = 'SDK Initialized Successfully: $message';
        });
      } else {
        setState(() {
          _isInitialized = false;
          _status = 'SDK Initialization Failed: $message';
        });
      }
    } on PlatformException catch (e) {
      setState(() => _status = 'Platform Error during init: ${e.message}');
    } catch (e) {
      setState(() => _status = 'Error during init: $e');
    }
  }

  Future<void> _createNewLoan() async {
    if (!_isInitialized) {
      setState(() => _status = 'Please initialize the SDK first.');
      return;
    }
    setState(() => _status = 'Creating new loan...');

    // Example loan request payload. Keys must match the LoanRequest constructor in Kotlin.
    final loanRequest = {
      "loan_reference": "LN-REF-20251017-1101",
      "client_unique_id": "CUST-20251017-1234",
      "product_id": "MUT-IND-3065",
      "branch_id": "ML1348",
      "source_system": "hotfoot",
      "business_profile": {
        "product": "LAP",
        "business_model": "Trading",
        "industry": "Fashion Apparel"
      },
      "data": {
        "borrower_details": {
          "entity_type": "individual",
          "name": "Shwetanka Srivastava",
          "dob": "24/01/1988",
          "mobile": "8197837043"
        }
      }
    };

    try {
      final result = await AbleCreditSdk.createNewLoan(loanRequest: loanRequest);
      if (result != null) {
        setState(() {
          _lastLoanId = result['applicationId'];
          _status = 'Loan created successfully! ID: $_lastLoanId';
        });
        log('Loan creation response: $result');
      } else {
        setState(() => _status = 'Loan creation failed: SDK returned null.');
      }
    } on PlatformException catch (e) {
      setState(() => _status = 'Platform Error creating loan: ${e.message}');
    } catch (e) {
      setState(() => _status = 'Error creating loan: $e');
    }
  }



  Future<void> _recordAudio() async {
    if (!_isInitialized) {
      setState(() => _status = 'Please initialize the SDK first.');
      return;
    }
    if (_lastLoanId == null) {
      setState(() => _status = 'Create a loan first to get an ID for audio recording.');
      return;
    }
    setState(() => _status = 'Recording audio...');
    try {
      await AbleCreditSdk.recordAudio(loanApplicationId: _lastLoanId!);
      setState(() => _status = 'Audio recording initiated.');
    } on PlatformException catch (e) {
      setState(() => _status = 'Platform Error recording audio: ${e.message}');
    } catch (e) {
      setState(() => _status = 'Error recording audio: $e');
    }
  }



  Future<void> _getSdkConfig() async {
    if (!_isInitialized) {
      setState(() => _status = 'Please initialize the SDK first.');
      return;
    }
    setState(() => _status = 'Getting SDK config...');
    try {
      final config = await AbleCreditSdk.getSdkConfig();
      setState(() => _status = 'SDK Config: ${config.toString()}');
      log('SDK Config: $config');
    } on PlatformException catch (e) {
      setState(() => _status = 'Platform Error getting config: ${e.message}');
    } catch (e) {
      setState(() => _status = 'Error getting config: $e');
    }
  }

  Future<void> _captureFamilyPhotos() async {
    if (!_isInitialized) {
      setState(() => _status = 'Please initialize the SDK first.');
      return;
    }
    if (_lastLoanId == null) {
      setState(() => _status = 'Create a loan first to get an ID for photo capture.');
      return;
    }

    if (await _handleCameraPermission()) {
      setState(() => _status = 'Capturing family photos...');
      try {
        await AbleCreditSdk.captureFamilyPhotos(loanApplicationId: _lastLoanId!);
        setState(() => _status = 'Family photo capture initiated.');
      } on PlatformException catch (e) {
        setState(() => _status = 'Platform Error capturing photos: ${e.message}');
      } catch (e) {
        setState(() => _status = 'Error capturing photos: $e');
      }
    }
  }

  Future<void> _captureBusinessPhotos() async {
    if (!_isInitialized) {
      setState(() => _status = 'Please initialize the SDK first.');
      return;
    }
    if (_lastLoanId == null) {
      setState(() => _status = 'Create a loan first to get an ID for photo capture.');
      return;
    }

    if (await _handleCameraPermission()) {
      setState(() => _status = 'Capturing business photos...');
      try {
        await AbleCreditSdk.captureBusinessPhotos(loanApplicationId: _lastLoanId!);
        setState(() => _status = 'Business photo capture initiated.');
      } on PlatformException catch (e) {
        setState(() => _status = 'Platform Error capturing photos: ${e.message}');
      } catch (e) {
        setState(() => _status = 'Error capturing photos: $e');
      }
    }
  }

  Future<void> _captureCollateralPhotos() async {
    if (!_isInitialized) {
      setState(() => _status = 'Please initialize the SDK first.');
      return;
    }
    if (_lastLoanId == null) {
      setState(() => _status = 'Create a loan first to get an ID for photo capture.');
      return;
    }

    if (await _handleCameraPermission()) {
      setState(() => _status = 'Capturing collateral photos...');
      try {
        await AbleCreditSdk.captureCollateralPhotos(loanApplicationId: _lastLoanId!);
        setState(() => _status = 'Collateral photo capture initiated.');
      } on PlatformException catch (e) {
        setState(() => _status = 'Platform Error capturing photos: ${e.message}');
      } catch (e) {
        setState(() => _status = 'Error capturing photos: $e');
      }
    }
  }

  Future<bool> _handleCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      var result = await Permission.camera.request();
      if (!result.isGranted) {
        setState(() {
          _status = 'Camera permission is required to capture photos.';
        });
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _initializeSdk,
                  child: const Text('1. Initialize SDK'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isInitialized ? _createNewLoan : null,
                  child: const Text('2. Create New Loan'),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 12),
                ElevatedButton( 
                  onPressed: _isInitialized && _lastLoanId != null ? _recordAudio : null,
                  child: const Text('3. Record Audio'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isInitialized && _lastLoanId != null ? _captureFamilyPhotos : null,
                  child: const Text('4a. Capture Family Photos'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isInitialized && _lastLoanId != null ? _captureBusinessPhotos : null,
                  child: const Text('4b. Capture Business Photos'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isInitialized && _lastLoanId != null ? _captureCollateralPhotos : null,
                  child: const Text('4c. Capture Collateral Photos'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isInitialized ? _getSdkConfig : null,
                  child: const Text('5. Get SDK Config'),
                ),
                const SizedBox(height: 40),
                Text(
                  'Status:',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
