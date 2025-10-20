import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../widgets/money_input.dart';

enum SimTab { payroll, credit, savings }

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});
  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  SimTab tab = SimTab.payroll;

  // ---- Planilla
  final payGrossCtrl = TextEditingController();
  final payContribCtrl = TextEditingController();

  // ---- Crédito
  final loanAmountCtrl = TextEditingController();
  final loanRateCtrl = TextEditingController(); // % anual
  final loanMonthsCtrl = TextEditingController(); // meses

  // ---- Ahorro
  final incomeCtrl = TextEditingController();
  final targetPctCtrl = TextEditingController(text: '20'); // % meta

  @override
  void dispose() {
    payGrossCtrl.dispose();
    payContribCtrl.dispose();
    loanAmountCtrl.dispose();
    loanRateCtrl.dispose();
    loanMonthsCtrl.dispose();
    incomeCtrl.dispose();
    targetPctCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SegControl(value: tab, onChanged: (v) => setState(() => tab = v)),
          const SizedBox(height: 16),

          if (tab == SimTab.payroll) _buildPayroll(),
          if (tab == SimTab.credit) _buildCredit(),
          if (tab == SimTab.savings) _buildSavings(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ================== Secciones ==================

  Widget _buildPayroll() {
    final gross = parseMoney(payGrossCtrl.text);
    final contrib = parseMoney(payContribCtrl.text);
    final net = math.max(0.0, gross - contrib).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          children: [
            MoneyInput(label: 'Ingreso bruto', controller: payGrossCtrl),
            const SizedBox(height: 12),
            MoneyInput(
              label: 'Aportes (ESSALUD/AFP/etc.)',
              controller: payContribCtrl,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ResultCard(title: 'Ingreso neto', value: formatCurrency(net)),
        const SizedBox(height: 8),
        const _Hint(
          'El neto se calcula restando los aportes/retenciones al ingreso bruto.',
        ),
      ],
    );
  }

  Widget _buildCredit() {
    final P = parseMoney(loanAmountCtrl.text);
    final i = _toDouble(loanRateCtrl.text) / 100 / 12; // mensual
    final n = int.tryParse(loanMonthsCtrl.text) ?? 0;

    final cuota = (i <= 0 || n <= 0)
        ? 0.0
        : (P * i) / (1 - math.pow(1 + i, -n));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          children: [
            MoneyInput(label: 'Monto', controller: loanAmountCtrl),
            const SizedBox(height: 12),
            TextField(
              controller: loanRateCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              ],
              decoration: const InputDecoration(labelText: 'Tasa anual (%)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: loanMonthsCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Meses'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ResultCard(title: 'Cuota estimada', value: formatCurrency(cuota)),
        const SizedBox(height: 8),
        const _Hint(
          'Cálculo con fórmula de anualidades. El resultado es referencial.',
        ),
      ],
    );
  }

  Widget _buildSavings() {
    final income = parseMoney(incomeCtrl.text);
    final pct = _toDouble(targetPctCtrl.text).clamp(0, 100);
    final suggested = income * (pct / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          children: [
            MoneyInput(label: 'Ingreso mensual', controller: incomeCtrl),
            const SizedBox(height: 12),
            TextField(
              controller: targetPctCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Meta de ahorro mensual (%)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ResultCard(title: 'Ahorro sugerido', value: formatCurrency(suggested)),
        const SizedBox(height: 8),
        const _Hint(
          'Intenta mantener un porcentaje constante de ahorro cada mes.',
        ),
      ],
    );
  }

  // ================== Helpers UI ==================

  double _toDouble(String text) {
    final t = text.replaceAll(',', '.').replaceAll(' ', '');
    return double.tryParse(t) ?? 0.0;
  }
}

class _SegControl extends StatelessWidget {
  final SimTab value;
  final ValueChanged<SimTab> onChanged;
  const _SegControl({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _SegButton(
            text: 'Planilla',
            selected: value == SimTab.payroll,
            onTap: () => onChanged(SimTab.payroll),
          ),
          _SegButton(
            text: 'Crédito',
            selected: value == SimTab.credit,
            onTap: () => onChanged(SimTab.credit),
          ),
          _SegButton(
            text: 'Ahorro',
            selected: value == SimTab.savings,
            onTap: () => onChanged(SimTab.savings),
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

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  const _ResultCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4FF),
        border: Border.all(color: const Color(0xFFCDD4FF), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        border: Border.all(color: const Color(0xFFFFE3A3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFFB45309))),
    );
  }
}
