class Debt {
  final String id;
  final String title; // (antes name)
  final double amount; // cuota mensual
  final DateTime dueDate;
  final bool paid;
  final double totalDebt; // saldo total
  final double? creditLimit; // opcional

  Debt({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.paid,
    required this.totalDebt,
    this.creditLimit,
  });

  Debt copyWith({bool? paid}) => Debt(
    id: id,
    title: title,
    amount: amount,
    dueDate: dueDate,
    paid: paid ?? this.paid,
    totalDebt: totalDebt,
    creditLimit: creditLimit,
  );
}
