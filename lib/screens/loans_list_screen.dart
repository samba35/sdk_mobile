import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdk/models/loan_model.dart';
import 'package:sdk/theme.dart';

class LoansListScreen extends StatelessWidget {
  final List<LoanModel> loans;
  final Function(LoanModel) onRecordAudio;
  final Function(LoanModel) onCaptureFamilyPhotos;
  final Function(LoanModel) onCaptureBusinessPhotos;
  final Function(LoanModel) onCaptureCollateralPhotos;

  const LoansListScreen({
    super.key,
    required this.loans,
    required this.onRecordAudio,
    required this.onCaptureFamilyPhotos,
    required this.onCaptureBusinessPhotos,
    required this.onCaptureCollateralPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Loans')),
      body: loans.isEmpty
          ? Center(
              child: Text(
                'No loans found',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];
                return _LoanCard(
                  loan: loan,
                  onRecordAudio: () => onRecordAudio(loan),
                  onCaptureFamilyPhotos: () => onCaptureFamilyPhotos(loan),
                  onCaptureBusinessPhotos: () => onCaptureBusinessPhotos(loan),
                  onCaptureCollateralPhotos: () =>
                      onCaptureCollateralPhotos(loan),
                );
              },
            ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onRecordAudio;
  final VoidCallback onCaptureFamilyPhotos;
  final VoidCallback onCaptureBusinessPhotos;
  final VoidCallback onCaptureCollateralPhotos;

  const _LoanCard({
    required this.loan,
    required this.onRecordAudio,
    required this.onCaptureFamilyPhotos,
    required this.onCaptureBusinessPhotos,
    required this.onCaptureCollateralPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.clientName,
                        style: AppTheme.lightTheme.textTheme.displayMedium
                            ?.copyWith(fontSize: 18),
                      ),
                      Text(
                        loan.reference,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    loan.status,
                    style: const TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Actions',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.mic,
                  label: 'Audio',
                  onPressed: onRecordAudio,
                ),
                _ActionButton(
                  icon: Icons.family_restroom,
                  label: 'Family',
                  onPressed: onCaptureFamilyPhotos,
                ),
                _ActionButton(
                  icon: Icons.store,
                  label: 'Business',
                  onPressed: onCaptureBusinessPhotos,
                ),
                _ActionButton(
                  icon: Icons.home_work,
                  label: 'Collateral',
                  onPressed: onCaptureCollateralPhotos,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
