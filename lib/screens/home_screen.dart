import 'package:flutter/material.dart';
import 'package:sdk/theme.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onCreateLoan;
  final VoidCallback onViewLoans;
  final VoidCallback onClearSdk;
  final bool isSdkInitialized;
  final int loanCount;

  const HomeScreen({
    super.key,
    required this.onCreateLoan,
    required this.onViewLoans,
    required this.onClearSdk,
    required this.isSdkInitialized,
    required this.loanCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AbleCredit SDK')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 40),
            _buildActionButton(
              context,
              label: 'Create New Loan',
              icon: Icons.add_circle_outline,
              onPressed: onCreateLoan,
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              label: 'View Loans ($loanCount)',
              icon: Icons.list_alt,
              onPressed: loanCount > 0 ? onViewLoans : null,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              label: 'Clear SDK',
              icon: Icons.delete_outline,
              onPressed: onClearSdk,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              isSdkInitialized ? Icons.check_circle : Icons.info_outline,
              size: 48,
              color: isSdkInitialized
                  ? AppTheme.successColor
                  : AppTheme.secondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              isSdkInitialized ? 'SDK Initialized' : 'SDK Not Initialized',
              style: AppTheme.lightTheme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isSdkInitialized
                  ? 'Ready to process loan applications'
                  : 'Tap "Create New Loan" to initialize and start',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    VoidCallback? onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? AppTheme.errorColor
        : isPrimary
        ? AppTheme.primaryColor
        : AppTheme.surfaceColor;
    final textColor = isPrimary || isDestructive
        ? Colors.white
        : AppTheme.textPrimary;

    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary || isDestructive ? color : Colors.white,
          foregroundColor: textColor,
          side: isPrimary || isDestructive
              ? null
              : BorderSide(color: Colors.grey.shade300),
          elevation: isPrimary ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon), const SizedBox(width: 12), Text(label)],
        ),
      ),
    );
  }
}
