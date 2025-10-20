class DebtDto {
  final String id;
  final String title; // (antes name)
  final double amount;
  final String dueDate; // ISO
  final bool paid;
  final double totalDebt;
  final double? creditLimit;

  DebtDto({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.paid,
    required this.totalDebt,
    this.creditLimit,
  });

  factory DebtDto.fromMap(Map<String, dynamic> m) => DebtDto(
    id: m['id'],
    title: m['title'] ?? m['name'], // compat
    amount: (m['amount'] as num).toDouble(),
    dueDate: m['dueDate'],
    paid: m['paid'] as bool,
    totalDebt: (m['totalDebt'] as num).toDouble(),
    creditLimit: m['creditLimit'] == null
        ? null
        : (m['creditLimit'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'dueDate': dueDate,
    'paid': paid,
    'totalDebt': totalDebt,
    'creditLimit': creditLimit,
  };
}
