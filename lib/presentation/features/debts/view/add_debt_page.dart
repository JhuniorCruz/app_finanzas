import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../presentation/widgets/money_input.dart';
import '../../../../domain/entities/debt.dart';
import '../../debts/controller/debts_controller.dart';

enum DebtType { creditCard, loan }

class AddDebtPage extends StatefulWidget {
  const AddDebtPage({super.key});
  @override
  State<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final dueDayCtrl = TextEditingController();
  final limitCtrl = TextEditingController();
  DebtType type = DebtType.creditCard;

  @override
  void dispose() {
    nameCtrl.dispose();
    amountCtrl.dispose();
    totalCtrl.dispose();
    dueDayCtrl.dispose();
    limitCtrl.dispose();
    super.dispose();
  }

  DateTime _nextDueFromDay(int day) {
    final now = DateTime.now();
    final clamp = day.clamp(1, 31);
    final thisMonth = DateTime(now.year, now.month, clamp);
    if (!thisMonth.isAfter(now)) {
      final next = DateTime(now.year, now.month + 1, 1);
      final lastDay = DateTime(next.year, next.month + 1, 0).day;
      final d = clamp.clamp(1, lastDay);
      return DateTime(next.year, next.month, d);
    }
    return thisMonth;
  }

  @override
  Widget build(BuildContext context) {
    final isCard = type == DebtType.creditCard;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva deuda')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre (Banco/Tarjeta/Préstamo)',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  MoneyInput(
                    controller: amountCtrl,
                    label: 'Cuota mensual',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dueDayCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Día de vencimiento (1-31)',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      final n = int.tryParse(v);
                      if (n == null || n < 1 || n > 31) return 'Día inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  MoneyInput(
                    controller: totalCtrl,
                    label: isCard ? 'Saldo actual' : 'Saldo total del préstamo',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tarjeta'),
                        selected: isCard,
                        onSelected: (_) =>
                            setState(() => type = DebtType.creditCard),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Préstamo'),
                        selected: !isCard,
                        onSelected: (_) => setState(() => type = DebtType.loan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isCard)
                    MoneyInput(
                      controller: limitCtrl,
                      label: 'Línea de crédito (opcional)',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _tipBox(isCard),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar'),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              final day = int.parse(dueDayCtrl.text);
              final due = _nextDueFromDay(day);
              final amount = parseMoney(amountCtrl.text);
              final total = parseMoney(totalCtrl.text);
              final limit = limitCtrl.text.trim().isEmpty
                  ? null
                  : parseMoney(limitCtrl.text);

              final debt = Debt(
                id: UniqueKey().toString(),
                title: nameCtrl.text.trim(),
                amount: amount,
                dueDate: due,
                paid: false,
                totalDebt: total,
                creditLimit: limit,
              );

              await context.read<DebtsController>().addDebt(debt);
              if (mounted) Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _tipBox(bool isCard) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFF),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      isCard
          ? 'Tip: Mantén el uso de tu tarjeta por debajo de 50% de la línea disponible.'
          : 'Tip: Paga a tiempo tu préstamo para evitar DPD.',
    ),
  );
}
