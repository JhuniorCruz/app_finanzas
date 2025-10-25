import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/scoring.dart';
import '../../../widgets/money_input.dart';

import '../../transactions/controller/transactions_controller.dart';
import '../../debts/controller/debts_controller.dart';
import '../../settings/controller/settings_controller.dart';

enum SimTab { payroll, credit, savings }

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  SimTab tab = SimTab.payroll;

  // PLANILLA
  final payGrossCtrl = TextEditingController(text: '');
  final payContribCtrl = TextEditingController(text: '');

  // CRÉDITO
  final loanAmountCtrl = TextEditingController(text: '');
  final loanRateCtrl = TextEditingController(text: ''); // % anual
  final loanMonthsCtrl = TextEditingController(text: '');

  // AHORRO
  final savingsTargetCtrl = TextEditingController(text: '');

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
    final profile = context.watch<SettingsController>().profile;
    final currentSavingsTarget = profile?.savingsTarget ?? 10.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700, // negrita
          fontFamily: 'Inter', // tu tipo de letra
          color: Color.fromRGBO(48, 50, 191, 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const _Header(),
          const SizedBox(height: 16.0),

          _Segmented3(
            value: tab,
            onChanged: (v) => setState(() => tab = v),
            labels: const ['Planilla', 'Crédito', 'Ahorro'],
          ),
          const SizedBox(height: 16.0),

          Text(
            _subtitleFor(tab),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 16.0),

          if (tab == SimTab.payroll) ..._buildPayroll(),
          if (tab == SimTab.credit) ..._buildCredit(),
          if (tab == SimTab.savings) ..._buildSavings(currentSavingsTarget),

          const SizedBox(height: 20.0),

          ElevatedButton.icon(
            icon: Icon(_buttonIconFor(tab)),
            label: const Text('Simular escenario'),
            onPressed: () => _runSimulation(context, currentSavingsTarget),
          ),

          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  // ---------- UI por pestaña ----------

  List<Widget> _buildPayroll() => [
    MoneyInput(label: 'Sueldo bruto mensual', controller: payGrossCtrl),
    const SizedBox(height: 12.0),
    MoneyInput(
      label: 'Aportes estimados (AFP, salud)',
      controller: payContribCtrl,
    ),
  ];

  List<Widget> _buildCredit() => [
    MoneyInput(label: 'Monto del préstamo', controller: loanAmountCtrl),
    const SizedBox(height: 12.0),
    _PercentInput(label: 'Tasa de interés anual (%)', controller: loanRateCtrl),
    const SizedBox(height: 12.0),
    _IntInput(label: 'Plazo (meses)', controller: loanMonthsCtrl),
  ];

  List<Widget> _buildSavings(double currentTarget) => [
    _PercentInput(
      label: 'Nueva meta de ahorro (%)',
      controller: savingsTargetCtrl,
    ),
    const SizedBox(height: 8.0),
    Text(
      'Meta actual: ${currentTarget.toStringAsFixed(0)}%',
      style: const TextStyle(color: Color(0xFF94A3B8)),
    ),
  ];

  // ---------- Simulación (hoja fusionada) ----------

  Future<void> _runSimulation(
    BuildContext context,
    double currentSavingsTarget,
  ) async {
    FocusScope.of(context).unfocus(); // cierra teclado

    final profile = context.read<SettingsController>().profile;
    if (profile == null) {
      _toast(context, 'Configura tu perfil en Ajustes antes de simular.');
      return;
    }

    final txs = context.read<TransactionsController>().items;
    final debts = context.read<DebtsController>().items;

    final baseM = _computeCurrentMetrics(txs, debts);
    final baseScore = _scoreFromMetrics(baseM, profile).score;

    switch (tab) {
      // ================= PLANILLA =================
      case SimTab.payroll:
        {
          final gross = parseCurrency(payGrossCtrl.text);
          final contrib = parseCurrency(payContribCtrl.text);
          final double net = (gross - contrib)
              .clamp(0.0, double.infinity)
              .toDouble();

          final simIncome = net;
          final simExpenses = baseM.expenses;
          final double simSavingsRate = simIncome == 0.0
              ? 0.0
              : ((simIncome - simExpenses) / simIncome) * 100.0;

          final simMetrics = _Metrics(
            income: simIncome,
            expenses: simExpenses,
            debtInstallments: baseM.debtInstallments,
            utilizationPct: baseM.utilizationPct,
            dpdAvg: baseM.dpdAvg,
            savingsRate: simSavingsRate,
          );
          final simScore = _scoreFromMetrics(simMetrics, profile).score;

          await _showFusionSheet(
            context,
            title: 'Resultado (Planilla)',
            summarySection: [
              _kv('Sueldo bruto', formatCurrency(gross)),
              _kv('Aportes estimados', formatCurrency(contrib)),
              const SizedBox(height: 8.0),
              _kvBig('Sueldo neto estimado', formatCurrency(net)),
              const SizedBox(height: 6.0),
              const Text(
                'El neto estimado se calcula restando los aportes obligatorios al bruto.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
            baseScore: baseScore,
            simScore: simScore,
            indicatorsSection: [
              _indicatorRow(
                'Deuda/Ingreso',
                '${(baseM.income == 0.0 ? 0.0 : (baseM.debtInstallments / baseM.income) * 100.0).toStringAsFixed(0)}%',
                '${(simIncome == 0.0 ? 0.0 : (baseM.debtInstallments / simIncome) * 100.0).toStringAsFixed(0)}%',
              ),
              _indicatorRow(
                'Utilización',
                '${baseM.utilizationPct.toStringAsFixed(0)}%',
                '${baseM.utilizationPct.toStringAsFixed(0)}%',
              ),
              _indicatorRow(
                '% Ahorro',
                '${baseM.savingsRate.toStringAsFixed(1)}%',
                '${simSavingsRate.toStringAsFixed(1)}%',
              ),
            ],
          );
          break;
        }

      // ================= CRÉDITO =================
      case SimTab.credit:
        {
          final P = parseCurrency(loanAmountCtrl.text);
          final annualPct = _parsePercent(loanRateCtrl.text); // 0..100
          final r = (annualPct / 100.0) / 12.0; // tasa mensual
          final n = int.tryParse(loanMonthsCtrl.text.trim()) ?? 0;

          if (P <= 0.0 || r.isNaN || r < 0.0 || n <= 0) {
            _toast(context, 'Completa monto, tasa y plazo válidos.');
            return;
          }

          final cuota = _annuityPayment(P, r, n);
          final totalPagado = cuota * n;
          final double intereses = (totalPagado - P)
              .clamp(0.0, double.infinity)
              .toDouble();

          // Simulación: cuota impacta en gastos y deuda/ingreso
          final simDebtInstallments = baseM.debtInstallments + cuota;
          final simExpenses = baseM.expenses + cuota;
          final double simSavingsRate = baseM.income == 0.0
              ? 0.0
              : ((baseM.income - simExpenses) / baseM.income) * 100.0;

          final simMetrics = _Metrics(
            income: baseM.income,
            expenses: simExpenses,
            debtInstallments: simDebtInstallments,
            utilizationPct:
                baseM.utilizationPct, // asumimos microcrédito sin línea
            dpdAvg: baseM.dpdAvg,
            savingsRate: simSavingsRate,
          );
          final simScore = _scoreFromMetrics(simMetrics, profile).score;

          await _showFusionSheet(
            context,
            title: 'Resultado (Crédito)',
            summarySection: [
              _kv('Monto del préstamo', formatCurrency(P)),
              _kv('Tasa anual', '${annualPct.toStringAsFixed(2)}%'),
              _kv('Plazo', '$n meses'),
              const SizedBox(height: 8.0),
              _kvBig('Cuota mensual estimada', formatCurrency(cuota)),
              _kv('Intereses totales aprox.', formatCurrency(intereses)),
            ],
            baseScore: baseScore,
            simScore: simScore,
            indicatorsSection: [
              _indicatorRow(
                'Deuda/Ingreso',
                '${(baseM.income == 0.0 ? 0.0 : (baseM.debtInstallments / baseM.income) * 100.0).toStringAsFixed(0)}%',
                '${(baseM.income == 0.0 ? 0.0 : (simDebtInstallments / baseM.income) * 100.0).toStringAsFixed(0)}%',
              ),
              _indicatorRow(
                'Utilización',
                '${baseM.utilizationPct.toStringAsFixed(0)}%',
                '${baseM.utilizationPct.toStringAsFixed(0)}%',
              ),
              _indicatorRow(
                '% Ahorro',
                '${baseM.savingsRate.toStringAsFixed(1)}%',
                '${simSavingsRate.toStringAsFixed(1)}%',
              ),
            ],
          );
          break;
        }

      // ================= AHORRO =================
      case SimTab.savings:
        {
          final newTarget = _parsePercent(savingsTargetCtrl.text);
          if (newTarget <= 0.0) {
            _toast(context, 'Ingresa una meta válida (> 0%).');
            return;
          }

          final baseScoreObj = _scoreFromMetrics(baseM, profile);
          final simScoreObj = calculateScore(
            ScoreFactors(
              dpd: baseM.dpdAvg,
              debtToIncome: baseM.income == 0.0
                  ? 0.0
                  : (baseM.debtInstallments / baseM.income) * 100.0,
              utilization: baseM.utilizationPct,
              savingsRate: baseM.savingsRate,
            ),
            Thresholds(
              debtToIncomeWarning: profile.debtToIncomeThreshold,
              utilizationWarning: profile.utilizationThreshold,
              savingsTarget: newTarget, // ← nuevo objetivo
            ),
          );

          await _showFusionSheet(
            context,
            title: 'Resultado (Ahorro)',
            summarySection: [
              _kv('Meta actual', '${currentSavingsTarget.toStringAsFixed(0)}%'),
              _kvBig(
                'Nueva meta de ahorro',
                '${newTarget.toStringAsFixed(0)}%',
              ),
              const SizedBox(height: 6.0),
              const Text(
                'Metas de ahorro por encima del 20% suelen tener impacto positivo sostenido.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
            baseScore: baseScoreObj.score,
            simScore: simScoreObj.score,
            indicatorsSection: [
              _indicatorRow(
                'Deuda/Ingreso',
                '${(baseM.income == 0.0 ? 0.0 : (baseM.debtInstallments / baseM.income) * 100.0).toStringAsFixed(0)}%',
                '${(baseM.income == 0.0 ? 0.0 : (baseM.debtInstallments / baseM.income) * 100.0).toStringAsFixed(0)}%',
              ),
              _indicatorRow(
                'Utilización',
                '${baseM.utilizationPct.toStringAsFixed(0)}%',
                '${baseM.utilizationPct.toStringAsFixed(0)}%',
              ),
              _indicatorRow(
                '% Ahorro',
                '${baseM.savingsRate.toStringAsFixed(1)}%',
                '${baseM.savingsRate.toStringAsFixed(1)}%',
              ),
            ],
          );
          break;
        }
    }
  }
}

// =================== Header & Segmented ===================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C6BF6), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18.0,
            offset: Offset(0.0, 8.0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulador',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 6.0),
          Text('¿Qué pasa si...?', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _Segmented3 extends StatelessWidget {
  final SimTab value;
  final ValueChanged<SimTab> onChanged;
  final List<String> labels;

  const _Segmented3({
    required this.value,
    required this.onChanged,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F5F9);
    final items = [SimTab.payroll, SimTab.credit, SimTab.savings];

    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24.0),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: List.generate(items.length, (i) {
          final sel = value == items[i];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20.0),
              onTap: () => onChanged(items[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: sel
                      ? const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8.0,
                            offset: Offset(0.0, 2.0),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: sel ? AppColors.foreground : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =================== Inputs numéricos auxiliares ===================

class _PercentInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _PercentInput({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: AppColors.foreground);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(hintText: '0', suffixText: '%'),
        ),
      ],
    );
  }
}

class _IntInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _IntInput({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: AppColors.foreground);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: const InputDecoration(hintText: '0'),
        ),
      ],
    );
  }
}

// =================== Cálculos, métricas y hoja fusionada ===================

class _Metrics {
  final double income; // ingresos del mes
  final double expenses; // gastos del mes
  final double debtInstallments; // suma de cuotas de deudas activas
  final double utilizationPct; // 0-100
  final int dpdAvg; // promedio de DPD
  final double savingsRate; // 0-100

  const _Metrics({
    required this.income,
    required this.expenses,
    required this.debtInstallments,
    required this.utilizationPct,
    required this.dpdAvg,
    required this.savingsRate,
  });
}

// Estado actual a partir de controllers (sin depender de modelos concretos aquí)
_Metrics _computeCurrentMetrics(List<dynamic> txList, List<dynamic> debts) {
  final now = DateTime.now();

  // ---- Transacciones del mes ----
  double income = 0.0;
  double expenses = 0.0;

  for (final t in txList) {
    final DateTime d = t.date as DateTime;
    if (d.month == now.month && d.year == now.year) {
      final String type = t.type as String;
      final double amt = (t.amount as num).toDouble();
      if (type == 'income') {
        income += amt;
      } else if (type == 'expense') {
        expenses += amt;
      }
    }
  }

  // ---- Deudas activas ----
  double debtInstallments = 0.0;
  double used = 0.0;
  double limit = 0.0;
  final List<int> dpdValues = [];

  for (final d in debts) {
    if (d.paid == true) continue;

    debtInstallments += (d.amount as num).toDouble();

    final num? cl = d.creditLimit as num?;
    if (cl != null && cl > 0) {
      used += (d.totalDebt as num).toDouble();
      limit += cl.toDouble();
    }

    final DateTime due = d.dueDate as DateTime;
    dpdValues.add(getDaysPastDue(due));
  }

  final int dpdAvg = dpdValues.isEmpty
      ? 0
      : (dpdValues.reduce((a, b) => a + b) / dpdValues.length).round();

  final double utilization = limit == 0.0 ? 0.0 : (used / limit) * 100.0;
  final double savingsRate = income == 0.0
      ? 0.0
      : ((income - expenses) / income) * 100.0;

  return _Metrics(
    income: income,
    expenses: expenses,
    debtInstallments: debtInstallments,
    utilizationPct: utilization,
    dpdAvg: dpdAvg,
    savingsRate: savingsRate,
  );
}

dynamic _scoreFromMetrics(_Metrics m, dynamic profile) {
  final double dti = m.income == 0.0
      ? 0.0
      : (m.debtInstallments / m.income) * 100.0;
  return calculateScore(
    ScoreFactors(
      dpd: m.dpdAvg,
      debtToIncome: dti,
      utilization: m.utilizationPct,
      savingsRate: m.savingsRate,
    ),
    Thresholds(
      debtToIncomeWarning: profile.debtToIncomeThreshold,
      utilizationWarning: profile.utilizationThreshold,
      savingsTarget: profile.savingsTarget,
    ),
  );
}

String _subtitleFor(SimTab t) {
  switch (t) {
    case SimTab.payroll:
      return 'Simula cómo cambiaría tu situación si pasas a planilla';
    case SimTab.credit:
      return 'Simula el impacto de solicitar un microcrédito';
    case SimTab.savings:
      return 'Proyecta tu puntaje aumentando tu meta de ahorro';
  }
}

IconData _buttonIconFor(SimTab t) {
  switch (t) {
    case SimTab.payroll:
      return Icons.show_chart_rounded;
    case SimTab.credit:
      return Icons.credit_card_rounded;
    case SimTab.savings:
      return Icons.autorenew_rounded;
  }
}

// cuota de anualidad (amortización) P * r / (1 - (1+r)^-n)
double _annuityPayment(double P, double r, int n) {
  if (r == 0.0) return P / n;
  final double pow = math.pow(1 + r, -n).toDouble();
  return P * r / (1 - pow);
}

double _parsePercent(String s) {
  final cleaned = s.replaceAll(',', '.').replaceAll('%', '').trim();
  return double.tryParse(cleaned) ?? 0.0;
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

Widget _kv(String k, String v) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4.0),
  child: Row(
    children: [
      Expanded(
        child: Text(k, style: const TextStyle(color: Color(0xFF64748B))),
      ),
      Text(
        v,
        style: const TextStyle(
          color: AppColors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
);

Widget _kvBig(String k, String v) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(k, style: const TextStyle(color: Color(0xFF64748B))),
    const SizedBox(height: 4.0),
    Text(
      v,
      style: const TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
      ),
    ),
  ],
);

// --------- Hoja combinada ---------

class _ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  const _ScoreCard({required this.title, required this.score});

  @override
  Widget build(BuildContext context) {
    final tag = score >= 80 ? 'Bueno' : (score >= 60 ? 'A mejorar' : 'Bajo');
    final tagColor = score >= 80
        ? const Color(0xFF16A34A)
        : (score >= 60 ? const Color(0xFFF59E0B) : const Color(0xFFDC2626));
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 8.0),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(999.0),
            ),
            child: Text(
              tag,
              style: TextStyle(color: tagColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _indicatorRow(String label, String a, String b) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6.0),
  child: Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(color: Color(0xFF64748B))),
      ),
      Text('$a  →  $b', style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  ),
);

Future<void> _showFusionSheet(
  BuildContext context, {
  required String title,
  required List<Widget> summarySection,
  required int baseScore,
  required int simScore,
  required List<Widget> indicatorsSection,
}) async {
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 16.0 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12.0),

              // Resumen textual
              ...summarySection,
              const Divider(height: 28.0),

              // Tarjetas: Antes vs Después
              const Text(
                'Comparación: Antes vs Después',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      title: 'Puntaje actual',
                      score: baseScore,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _ScoreCard(
                      title: 'Puntaje simulado',
                      score: simScore,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              // Indicadores
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Indicadores',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ...indicatorsSection,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } catch (e) {
    // Respaldo si algo fallara al abrir la hoja
    // ignore: use_build_context_synchronously
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...summarySection,
              const SizedBox(height: 12.0),
              _indicatorRow('Puntaje actual', '$baseScore', '$baseScore'),
              _indicatorRow('Puntaje simulado', '$simScore', '$simScore'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
