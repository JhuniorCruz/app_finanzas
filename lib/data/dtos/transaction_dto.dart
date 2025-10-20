class TransactionDto {
  final String id;
  final String type; // 'income' | 'expense'
  final String category;
  final double amount;
  final String date; // ISO
  final String? note;
  final double? gross;
  final double? net;

  TransactionDto({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    this.gross,
    this.net,
  });

  factory TransactionDto.fromMap(Map<String, dynamic> m) => TransactionDto(
    id: m['id'],
    type: m['type'],
    category: m['category'],
    amount: (m['amount'] as num).toDouble(),
    date: m['date'],
    note: m['note'],
    gross: m['gross'] == null ? null : (m['gross'] as num).toDouble(),
    net: m['net'] == null ? null : (m['net'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'category': category,
    'amount': amount,
    'date': date,
    'note': note,
    'gross': gross,
    'net': net,
  };
}
