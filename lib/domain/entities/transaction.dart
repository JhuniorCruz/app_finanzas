class FinanceTx {
  final String id;
  final String type; // 'income' | 'expense'
  final String category;
  final double amount; // positivo ingresos, negativo gastos
  final DateTime date;
  final String? note; // opcional (gastos)
  final double? gross; // opcional (ingresos)
  final double? net; // opcional (ingresos)

  FinanceTx({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    this.gross,
    this.net,
  });
}
