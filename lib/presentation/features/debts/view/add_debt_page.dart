import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../presentation/widgets/money_input.dart';
import '../../../../domain/entities/debt.dart';
import '../controller/debts_controller.dart';

enum DebtType { creditCard, loan }

class AddDebtPage extends StatefulWidget {
  const AddDebtPage({super.key});
  @override
  State<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  DebtType type = DebtType.creditCard;

  final nameCtrl = TextEditingController();
  final feeCtrl = TextEditingController(); // cuota mensual
  final totalCtrl = TextEditingController(); // deuda total actual
  final limitCtrl = TextEditingController(); // línea total (solo tarjeta)
  final dueDayCtrl = TextEditingController(text: '25');

  int get _dueDay => int.tryParse(dueDayCtrl.text.trim()) ?? 0;

  @override
  void dispose() {
    nameCtrl.dispose();
    feeCtrl.dispose();
    totalCtrl.dispose();
    limitCtrl.dispose();
    dueDayCtrl.dispose();
    super.dispose();
  }

  DateTime _nextDueDateFromDay(int day) {
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
    final isCard = (type == DebtType.creditCard);

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar deuda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tipo de deuda', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          _TypeButton(
            selected: isCard,
            icon: Icons.credit_card_rounded,
            title: 'Tarjeta de crédito',
            onTap: () => setState(() => type = DebtType.creditCard),
          ),
          const SizedBox(height: 8),
          _TypeButton(
            selected: !isCard,
            icon: Icons.account_balance_rounded,
            title: 'Préstamo / Crédito',
            onTap: () => setState(() => type = DebtType.loan),
          ),
          const SizedBox(height: 16),

          Text(
            'Nombre de la deuda',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(hintText: 'Ej: Tarjeta Banco X'),
          ),

          const SizedBox(height: 16),
          MoneyInput(label: 'Cuota mensual', controller: feeCtrl),
          const SizedBox(height: 12),
          MoneyInput(label: 'Deuda total actual', controller: totalCtrl),
          if (isCard) ...[
            const SizedBox(height: 12),
            MoneyInput(label: 'Línea de crédito total', controller: limitCtrl),
          ],

          const SizedBox(height: 16),
          Text(
            'Día de vencimiento (del mes)',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: dueDayCtrl,
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: false,
            ),
            inputFormatters: [
              //borre un const
              FilteringTextInputFormatter.digitsOnly, // solo números
              LengthLimitingTextInputFormatter(2), // máx 2 dígitos
              DayOfMonthFormatter(), // fuerza 1–31
            ],
            decoration: const InputDecoration(hintText: 'Del 1 al 31'),
          ),
          const SizedBox(height: 6),
          const Text(
            'Día del mes en que vence el pago (1-31)',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),

          const SizedBox(height: 16),
          _TipBox(isCard: isCard),

          const SizedBox(height: 24),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final fee = parseCurrency(feeCtrl.text);
              final total = parseCurrency(totalCtrl.text);
              final limit = parseCurrency(limitCtrl.text);
              final day = _dueDay;

              if (name.isEmpty ||
                  fee <= 0 ||
                  total <= 0 ||
                  day < 1 ||
                  day > 31) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Revisa los campos: día 1–31 y montos válidos',
                    ),
                  ),
                );
                return;
              }

              final due = _nextDueDateFromDay(day);

              // Nueva arquitectura: crear entidad y delegar al controller
              final debt = Debt(
                id: UniqueKey().toString(),
                title: name,
                amount: fee,
                totalDebt: total,
                creditLimit: isCard && limit > 0 ? limit : null,
                dueDate: due,
                paid: false,
              );

              await context.read<DebtsController>().addDebt(debt);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ),
      ),
    );
  }
}

// ======= helpers UI =======

class _TypeButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _TypeButton({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(.12)
                    : AppColors.inputBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.foreground
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final bool isCard;
  const _TipBox({required this.isCard});

  @override
  Widget build(BuildContext context) {
    final text = isCard
        ? 'Tip: La utilización de tu tarjeta afecta tu puntaje educativo. Intenta mantenerla por debajo del 50% de tu línea disponible.'
        : 'Tip: Pagar a tiempo tu préstamo ayuda a evitar DPD y mejora tu puntaje educativo.';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF475569))),
    );
  }
}

/// Formatter que asegura que el campo solo sea 1–31.
/// (Se apoya en digitsOnly + lengthLimiter; aquí corregimos el rango.)
class DayOfMonthFormatter extends TextInputFormatter {
  const DayOfMonthFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final t = newValue.text;
    if (t.isEmpty) return newValue;

    final v = int.tryParse(t);
    if (v == null) return oldValue;

    final clamped = v.clamp(1, 31);
    final text = clamped.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
