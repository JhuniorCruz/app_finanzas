import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/scoring.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/kpi_card.dart' as k;

import '../../score/view/score_detail_page.dart';
import '../../debts/controller/debts_controller.dart';
import '../../transactions/controller/transactions_controller.dart';
import '../../score/controller/score_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loaded = false;

  // Porcentajes seguros (sin NaN/Infinity) y acotados
  double _pct(double num, double den) {
    if (den <= 0) return 0;
    final v = (num / den) * 100.0;
    if (v.isNaN || v.isInfinite) return 0;
    return v.clamp(0, 999).toDouble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    // Cargamos datos mínimos para que el dashboard calcule
    Future.microtask(() async {
      if (mounted) {
        context.read<TransactionsController>().load();
        context.read<DebtsController>().load();
        context.read<ScoreController>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionsController>();
    final debtVm = context.watch<DebtsController>();
    final scoreVm = context.watch<ScoreController>();

    final now = DateTime.now();
    final txs = txVm.items;

    final monthTx = txs
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    final double totalIncome = monthTx
        .where((t) => t.type == 'income')
        .fold<double>(0.0, (s, t) => s + t.amount);

    final double totalExpenses = monthTx
        .where((t) => t.type == 'expense')
        .fold<double>(0.0, (s, t) => s + t.amount);

    final double available = totalIncome - totalExpenses;

    // ---- Gastos por categoría (ordenado desc) ----
    final Map<String, double> expensesByCat = {};
    for (final t in monthTx.where((t) => t.type == 'expense')) {
      expensesByCat[t.category] = (expensesByCat[t.category] ?? 0.0) + t.amount;
    }

    // ---- Métricas y score educativo ----
    final debts = debtVm.items;
    final dpdList = debts
        .where((d) => !d.paid)
        .map((d) => getDaysPastDue(d.dueDate))
        .toList();
    final int dpdAvg = dpdList.isEmpty
        ? 0
        : (dpdList.reduce((a, b) => a + b) / dpdList.length).round();

    final double debtInstallments = debts
        .where((d) => !d.paid)
        .fold<double>(0.0, (s, d) => s + d.amount);

    final double debtToIncome = _pct(debtInstallments, totalIncome);

    double utilization = 0.0;
    final withLimit = debts
        .where((d) => d.creditLimit != null && d.creditLimit! > 0)
        .toList();
    if (withLimit.isNotEmpty) {
      final double used = withLimit.fold<double>(
        0.0,
        (s, d) => s + d.totalDebt,
      );
      final double limit = withLimit.fold<double>(
        0.0,
        (s, d) => s + (d.creditLimit ?? 0.0),
      );
      utilization = _pct(used, limit);
    }

    final double savingsRate = _pct(totalIncome - totalExpenses, totalIncome);

    final thresholds = scoreVm.thresholds ?? defaultThresholds;

    final score = calculateScore(
      ScoreFactors(
        dpd: dpdAvg,
        debtToIncome: debtToIncome,
        utilization: utilization,
        savingsRate: savingsRate,
      ),
      thresholds,
    );

    final kpiStatus = {
      'good': k.KpiStatus.good,
      'warning': k.KpiStatus.warning,
      'danger': k.KpiStatus.danger,
    }[score.status]!;

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Header “Mi Control” =====
          _BalanceHeaderCard(
            available: available,
            income: totalIncome,
            expenses: totalExpenses,
          ),
          const SizedBox(height: 16),

          // ===== Acciones rápidas =====
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/addIncome'),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar ingreso'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.foreground,
                      side: const BorderSide(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/addExpense'),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar gasto'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const _InfoBanner(
            text:
                'El puntaje educativo es una guía, no reemplaza scores oficiales',
          ),
          const SizedBox(height: 12),

          // ===== Indicadores financieros =====
          Text(
            'Indicadores financieros',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              k.KpiCard(
                title: '% Ahorro',
                value: '${savingsRate.toStringAsFixed(1)}%',
                status: savingsRate >= thresholds.savingsTarget
                    ? k.KpiStatus.good
                    : k.KpiStatus.warning,
                icon: Icons.savings_rounded,
              ),
              k.KpiCard(
                title: 'Deuda/Ingreso',
                value: '${debtToIncome.toStringAsFixed(0)}%',
                status: debtToIncome <= thresholds.debtToIncomeWarning
                    ? k.KpiStatus.good
                    : k.KpiStatus.warning,
                icon: Icons.trending_down_rounded,
              ),
              k.KpiCard(
                title: 'Utilización',
                value: '${utilization.toStringAsFixed(0)}%',
                status: utilization <= thresholds.utilizationWarning
                    ? k.KpiStatus.good
                    : k.KpiStatus.danger,
                icon: Icons.credit_card_rounded,
              ),
              k.KpiCard(
                title: 'Puntaje Educativo',
                value: score.score.toString(),
                status: kpiStatus,
                icon: Icons.insights_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScoreDetailPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ===== Gráfico: Gastos por categoría =====
          if (expensesByCat.isNotEmpty) ...[
            Text(
              'Gastos por categoría',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
                child: _ExpenseBarChart(data: expensesByCat),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ================== Widgets auxiliares (idénticos) ==================

class _BalanceHeaderCard extends StatelessWidget {
  final double available, income, expenses;
  const _BalanceHeaderCard({
    required this.available,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C6BF6), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 10),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Mi Control',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Saldo disponible este mes',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatCurrency(available),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  icon: Icons.south_west_rounded,
                  label: 'Ingresos',
                  value: formatCurrency(income),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatPill(
                  icon: Icons.north_east_rounded,
                  label: 'Gastos',
                  value: formatCurrency(expenses),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ingresos',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        border: Border.all(color: const Color(0xFFFFE3A3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFB45309), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFFB45309)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gráfico de barras para "Gastos por categoría" con ejes legibles
class _ExpenseBarChart extends StatelessWidget {
  final Map<String, double> data;
  const _ExpenseBarChart({required this.data});

  double _niceInterval(double yMax) {
    if (yMax <= 50) return 10;
    if (yMax <= 200) return 50;
    if (yMax <= 600) return 100;
    if (yMax <= 1200) return 200;
    if (yMax <= 3000) return 500;
    if (yMax <= 6000) return 1000;
    return 2000;
  }

  @override
  Widget build(BuildContext context) {
    // Ordenamos por monto (absoluto) desc
    final keys = data.keys.toList()
      ..sort((a, b) => (data[b] ?? 0).abs().compareTo((data[a] ?? 0).abs()));

    // Usamos valores absolutos para todo el cálculo
    final valuesAbs = keys.map((k) => (data[k] ?? 0).abs()).toList();

    final maxVal = valuesAbs.isEmpty ? 0.0 : valuesAbs.reduce(math.max);
    // Calcula el paso con el máximo real y agrega un escalón extra arriba
    final step = _niceInterval(maxVal);
    final maxY = maxVal == 0
        ? step * 5
        : ((maxVal / step).ceil() + 1) * step; // +1 step = margen superior

    const palette = [
      Color(0xFF22C55E),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF3B82F6),
      Color(0xFF14B8A6),
    ];

    bool _isMultiple(double v, double base) {
      const eps = 1e-6;
      final r = v % base;
      return r.abs() < eps || (base - r).abs() < eps;
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 12,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: step,
                getTitlesWidget: (value, _) {
                  // Solo mostramos múltiplos del intervalo…
                  bool isMultiple(double v, double base) {
                    const eps = 1e-6;
                    final r = v % base;
                    return r.abs() < eps || (base - r).abs() < eps;
                  }

                  if (!isMultiple(value, step)) return const SizedBox.shrink();

                  // …y ocultamos la etiqueta del valor máximo para no pegarla al borde superior
                  const epsTop = 1e-3;
                  if ((maxY - value).abs() < epsTop)
                    return const SizedBox.shrink();

                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Categoría de gasto',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
              axisNameSize: 35,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= keys.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Transform.rotate(
                      angle: -0.6,
                      child: Text(
                        keys[i],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) {
                final name = keys[group.x.toInt()];
                return BarTooltipItem(
                  '$name\n${formatCurrency(rod.toY)}',
                  const TextStyle(fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          barGroups: List.generate(keys.length, (i) {
            final y = valuesAbs[i]; // <- valor positivo siempre
            final color = palette[i % palette.length];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: y,
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [color.withOpacity(.45), color],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
