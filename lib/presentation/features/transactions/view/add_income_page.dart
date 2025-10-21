import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../widgets/money_input.dart';
import '../controller/transactions_controller.dart';

enum IncomeKind { recibo, planilla }

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  IncomeKind kind = IncomeKind.recibo;

  final grossCtrl = TextEditingController(); // bruto
  final discCtrl = TextEditingController(); // retenciones/aportes

  double get gross => parseCurrency(grossCtrl.text);
  double get disc => parseCurrency(discCtrl.text);
  double get net =>
      ((gross - disc).clamp(0.0, double.infinity) as num).toDouble();

  @override
  void initState() {
    super.initState();
    grossCtrl.addListener(_recalc);
    discCtrl.addListener(_recalc);
  }

  void _recalc() => setState(() {});

  @override
  void dispose() {
    grossCtrl.dispose();
    discCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecibo = kind == IncomeKind.recibo;

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar ingreso')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Selector tipo de ingreso
          _SegmentedKind(
            value: kind,
            onChanged: (k) {
              setState(() {
                kind = k;
                // opcional: limpiar descuentos al cambiar
                // discCtrl.text = '';
              });
            },
          ),
          const SizedBox(height: 18),

          // Monto bruto
          MoneyInput(label: 'Monto bruto', controller: grossCtrl),

          const SizedBox(height: 16),

          // Retenciones / Aportes
          MoneyInput(
            label: isRecibo
                ? 'Retenciones (impuestos)'
                : 'Aportes (AFP/ONP, salud, etc.)',
            controller: discCtrl,
          ),

          const SizedBox(height: 18),

          // Neto estimado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4FF),
              border: Border.all(color: const Color(0xFFCDD4FF)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Neto estimado',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatCurrency(net),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            isRecibo
                ? 'El monto neto se calcula restando las retenciones al bruto'
                : 'El monto neto se calcula restando los aportes obligatorios al bruto',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.foreground.withOpacity(.7),
            ),
          ),

          const SizedBox(height: 100), // espacio para que no lo tape el botón
        ],
      ),

      // Botón fijo inferior
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: gross > 0
                  ? () {
                      context.read<TransactionsController>().addIncome(
                        category: isRecibo ? 'recibo' : 'planilla',
                        gross: gross,
                        netAmount: net,
                        date: DateTime.now(),
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Guardar'),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selector “Recibos / Planilla” con estilo pastilla
class _SegmentedKind extends StatelessWidget {
  final IncomeKind value;
  final ValueChanged<IncomeKind> onChanged;
  const _SegmentedKind({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F5F9); // gris muy claro
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _SegButton(
            text: 'Recibos',
            selected: value == IncomeKind.recibo,
            onTap: () => onChanged(IncomeKind.recibo),
          ),
          _SegButton(
            text: 'Planilla',
            selected: value == IncomeKind.planilla,
            onTap: () => onChanged(IncomeKind.planilla),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _SegButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.foreground : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
