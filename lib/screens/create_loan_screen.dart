import 'package:flutter/material.dart';
import 'package:sdk/theme.dart';

class CreateLoanScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;

  const CreateLoanScreen({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CreateLoanScreen> createState() => _CreateLoanScreenState();
}

class _CreateLoanScreenState extends State<CreateLoanScreen> {
  // Hardcoded for demo, but could be form fields
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    // Demo payload
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

    widget.onSubmit(loanRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Loan Application')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Create Demo Loan',
              style: AppTheme.lightTheme.textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'This will initialize the SDK (if needed) and create a new loan application with sample data.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _submit,
                child: widget.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Loan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
