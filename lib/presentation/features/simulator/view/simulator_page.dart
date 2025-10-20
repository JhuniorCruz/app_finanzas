import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../presentation/widgets/money_input.dart';

enum SimTab { payroll, credit, savings }

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});
  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  SimTab tab = SimTab.payroll;

  final payGrossCtrl = TextEditingController();
  final payContribCtrl = TextEditingController();

  final loanAmountCtrl = TextEditingController();
  final loanRateCtrl = TextEditingController();
  final loanMonthsCtrl = TextEditingController();

  final savingsTargetCtrl = TextEditingController();

  @override
  void dispose() {
    payGrossCtrl.dispose();
    payContribCtrl.dispose();
    loanAmountCtrl.dispose();
    loanRateCtrl.dispose();
    loanMonthsCtrl.dispose();
    savingsTargetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<SimTab>(
            segments: const [
              ButtonSegment(value: SimTab.payroll, label: Text('Planilla')),
              ButtonSegment(value: SimTab.credit, label: Text('Crédito')),
              ButtonSegment(value: SimTab.savings, label: Text('Ahorro')),
            ],
            selected: {tab},
            onSelectionChanged: (s) => setState(() => tab = s.first),
          ),
          const SizedBox(height: 12),

          if (tab == SimTab.payroll) _buildPayroll(),
          if (tab == SimTab.credit) _buildCredit(),
          if (tab == SimTab.savings) _buildSavings(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // --- secciones ---

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
    ),
    child: child,
  );

  Widget _buildPayroll() {
    final gross = _toDouble(payGrossCtrl.text);
    final contrib = _toDouble(payContribCtrl.text);
    final net = math.max(0, gross - contrib);

    return Column(
      children: [
        _card(
          Column(
            children: [
              MoneyInput(controller: payGrossCtrl, label: 'Ingreso bruto'),
              const SizedBox(height: 12),
              MoneyInput(
                controller: payContribCtrl,
                label: 'Aportes (ESSALUD/AFP/etc.)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _result('Ingreso neto', net.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildCredit() {
    final P = _toDouble(loanAmountCtrl.text);
    final i = (_toDouble(loanRateCtrl.text) / 100) / 12;
    final n = int.tryParse(loanMonthsCtrl.text) ?? 0;
    final cuota = (i == 0 || n == 0) ? 0 : (P * i) / (1 - math.pow(1 + i, -n));

    return Column(
      children: [
        _card(
          Column(
            children: [
              MoneyInput(controller: loanAmountCtrl, label: 'Monto'),
              const SizedBox(height: 12),
              TextField(
                controller: loanRateCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Tasa anual (%)'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: loanMonthsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Meses'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _result('Cuota estimada', cuota.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildSavings() {
    final pct = _toDouble(savingsTargetCtrl.text);
    return Column(
      children: [
        _card(
          TextField(
            controller: savingsTargetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Meta de ahorro mensual (%)',
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        const SizedBox(height: 12),
        _result('Puntaje educativo estimado', pct.toStringAsFixed(0)),
      ],
    );
  }

  Widget _result(String title, String value) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
    ),
    child: Row(
      children: [
        Expanded(child: Text(title)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );

  double _toDouble(String t) =>
      double.tryParse(t.replaceAll(',', '').replaceAll(' ', '')) ?? 0.0;
}
