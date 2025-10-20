import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
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
  DebtType type = DebtType.creditCard;

  final nameCtrl = TextEditingController();
  final feeCtrl = TextEditingController(); // cuota mensual
  final totalCtrl = TextEditingController(); // deuda total / saldo actual
  final limitCtrl = TextEditingController(); // línea (solo tarjeta)
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
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final lastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
      final d = clamp.clamp(1, lastDay);
      return DateTime(nextMonth.year, nextMonth.month, d);
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
          // ===== Tipo de deuda =====
          Text('Tipo de deuda', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TypeButton(
                  icon: Icons.credit_card,
                  title: 'Tarjeta',
                  selected: isCard,
                  onTap: () => setState(() => type = DebtType.creditCard),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TypeButton(
                  icon: Icons.account_balance_rounded,
                  title: 'Préstamo',
                  selected: !isCard,
                  onTap: () => setState(() => type = DebtType.loan),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== Card con campos =====
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre (Banco/Tarjeta/Préstamo)',
                  ),
                ),
                const SizedBox(height: 12),

                MoneyInput(label: 'Cuota mensual', controller: feeCtrl),
                const SizedBox(height: 12),

                // Día de vencimiento (1..31)
                TextField(
                  controller: dueDayCtrl,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // solo números
                    LengthLimitingTextInputFormatter(2), // máx 2 dígitos
                    DayOfMonthFormatter(), // fuerza 1–31
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Día de vencimiento',
                    hintText: 'Del 1 al 31',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Día del mes en que vence el pago (1-31)',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),

                const SizedBox(height: 12),

                MoneyInput(
                  label: isCard ? 'Saldo actual' : 'Saldo total del préstamo',
                  controller: totalCtrl,
                ),

                const SizedBox(height: 12),

                if (isCard)
                  MoneyInput(
                    label: 'Línea de crédito (opcional)',
                    controller: limitCtrl,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _TipBox(isCard: isCard),

          const SizedBox(height: 24),
        ],
      ),

      // ===== Botón Guardar (estilo original) =====
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final fee = parseMoney(feeCtrl.text);
              final total = parseMoney(totalCtrl.text);
              final limit = (limitCtrl.text.trim().isEmpty)
                  ? null
                  : parseMoney(limitCtrl.text);

              if (name.isEmpty ||
                  fee <= 0 ||
                  total <= 0 ||
                  _dueDay < 1 ||
                  _dueDay > 31) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Revisa los campos y vuelve a intentar'),
                  ),
                );
                return;
              }

              final due = _nextDueDateFromDay(_dueDay);

              final debt = Debt(
                id: UniqueKey().toString(),
                title: name,
                amount: fee,
                dueDate: due,
                paid: false,
                totalDebt: total,
                creditLimit: limit,
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

// =================== Widgets de UI (fiel al diseño original) ===================

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FF),
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
            // Indicador circular (marca de selección)
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
