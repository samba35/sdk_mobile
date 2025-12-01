class LoanModel {
  final String id;
  final String reference;
  final String clientName;
  final String amount;
  final String status;
  final DateTime createdAt;

  LoanModel({
    required this.id,
    required this.reference,
    required this.clientName,
    required this.amount,
    required this.status,
    required this.createdAt,
  });
}
