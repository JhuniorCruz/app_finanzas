import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../presentation/widgets/money_input.dart';
import '../../transactions/controller/transactions_controller.dart';

enum IncomeKind { recibo, planilla }

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});
  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  IncomeKind kind = IncomeKind.recibo;
  final grossCtrl = TextEditingController();
  final discCtrl = TextEditingController();

  double get gross => parseMoney(grossCtrl.text);
  double get disc => parseMoney(discCtrl.text);
  double get net => (gross - disc).clamp(0, double.infinity);

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
          _segmented(value: kind, onChanged: (v) => setState(() => kind = v)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                MoneyInput(label: 'Ingreso bruto', controller: grossCtrl),
                const SizedBox(height: 12),
                MoneyInput(
                  label: isRecibo
                      ? 'Retenciones (impuestos)'
                      : 'Aportes (AFP/ONP, salud, etc.)',
                  controller: discCtrl,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          _resultCard('Neto estimado', formatCurrency(net)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar'),
            onPressed: gross > 0
                ? () async {
                    await context.read<TransactionsController>().addIncome(
                      category: isRecibo ? 'recibo' : 'planilla',
                      gross: gross,
                      netAmount: net,
                      date: DateTime.now(),
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                : null,
          ),
        ),
      ),
    );
  }

  Widget _segmented({
    required IncomeKind value,
    required ValueChanged<IncomeKind> onChanged,
  }) {
    return SegmentedButton<IncomeKind>(
      segments: const [
        ButtonSegment(value: IncomeKind.recibo, label: Text('Recibos')),
        ButtonSegment(value: IncomeKind.planilla, label: Text('Planilla')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }

  Widget _resultCard(String title, String value) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F4FF),
      border: Border.all(color: const Color(0xFFCDD4FF), width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(color: Color(0xFF475569))),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
