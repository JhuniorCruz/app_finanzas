import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/scoring.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../score/controller/score_controller.dart';
import '../../transactions/view/add_income_page.dart';
import '../../transactions/view/add_expense_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() async {
        await context.read<DashboardController>().load();
        // Score para indicadores (no bloquea UI)
        context.read<ScoreController>().load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardController>();
    if (vm.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tx = vm.items;
    final now = DateTime.now();
    final monthTx = tx
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    final totalIncome = monthTx
        .where((t) => t.amount >= 0)
        .fold<double>(0.0, (s, t) => s + t.amount);
    final totalExpenses = monthTx
        .where((t) => t.amount < 0)
        .fold<double>(0.0, (s, t) => s + t.amount.abs());
    final available = totalIncome - totalExpenses;

    // Gastos por categoría
    final Map<String, double> expensesByCat = {};
    for (final t in monthTx.where((t) => t.amount < 0)) {
      expensesByCat[t.category] =
          (expensesByCat[t.category] ?? 0) + t.amount.abs();
    }
    final sortedKeys = expensesByCat.keys.toList()
      ..sort(
        (a, b) => (expensesByCat[b] ?? 0).compareTo(expensesByCat[a] ?? 0),
      );
    final barGroups = List.generate(sortedKeys.length, (i) {
      final k = sortedKeys[i];
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: expensesByCat[k] ?? 0, width: 14)],
      );
    });

    // Indicadores (del ScoreController)
    final scoreVm = context.watch<ScoreController>();
    final sf = scoreVm.factors;
    final result = scoreVm.result;

    final savingsRate =
        sf?.savingsRate ??
        _safePct(totalIncome == 0 ? 0 : (available / totalIncome * 100));
    final dti = sf?.debtToIncome ?? 0.0;
    final utilization = sf?.utilization ?? 0.0;
    final eduScore =
        result?.score ?? _educationalScoreFallback(totalIncome, totalExpenses);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Inicio', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),

            _HeroCard(
              available: available,
              incomes: totalIncome,
              expenses: totalExpenses,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar ingreso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddIncomePage()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar gasto'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpensePage()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _NoticeCard(
              text:
                  'El puntaje educativo es una guía, no reemplaza scores oficiales',
            ),
            const SizedBox(height: 16),

            Text(
              'Indicadores financieros',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: _kpiWidth(context),
                  child: _IndicatorCard(
                    title: '% Ahorro',
                    value: '${savingsRate.toStringAsFixed(1)}%',
                    bgFrom: const Color(0xFFEFFDF5),
                    bgTo: const Color(0xE6D1F7E8),
                    icon: Icons.savings_rounded,
                    iconBg: const Color(0xFFE8FFF3),
                    valueColor: const Color(0xFF16A34A),
                  ),
                ),
                SizedBox(
                  width: _kpiWidth(context),
                  child: _IndicatorCard(
                    title: 'Deuda/Ingreso',
                    value: '${dti.toStringAsFixed(0)}%',
                    bgFrom: const Color(0xFFF0FFF9),
                    bgTo: const Color(0xE6CFFFEA),
                    icon: Icons.trending_down_rounded,
                    iconBg: const Color(0xFFEAFEF6),
                    valueColor: const Color(0xFF047857),
                  ),
                ),
                SizedBox(
                  width: _kpiWidth(context),
                  child: _IndicatorCard(
                    title: 'Utilización',
                    value: '${utilization.toStringAsFixed(0)}%',
                    bgFrom: const Color(0xFFFFF1F2),
                    bgTo: const Color(0xE6FFD1D5),
                    icon: Icons.credit_card_rounded,
                    iconBg: const Color(0xFFFFEEF0),
                    valueColor: const Color(0xFFB91C1C),
                  ),
                ),
                SizedBox(
                  width: _kpiWidth(context),
                  child: _IndicatorCard(
                    title: 'Puntaje Educativo',
                    value: '$eduScore',
                    bgFrom: const Color(0xFFFFF7E8),
                    bgTo: const Color(0xE6FFE7B5),
                    icon: Icons.query_stats_rounded,
                    iconBg: const Color(0xFFFFF1DE),
                    valueColor: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (barGroups.isNotEmpty) ...[
              Text(
                'Gastos por categoría',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _BarCard(keysLabels: sortedKeys, groups: barGroups),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  double _kpiWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const padding = 16.0;
    const gap = 12.0;
    return (w - padding * 2 - gap) / 2;
  }

  int _educationalScoreFallback(double totalIncome, double totalExpenses) {
    final v = clampScore(
      100 -
          math.min(
            totalExpenses / (totalIncome == 0 ? 1 : totalIncome) * 100,
            100,
          ),
    );
    return v.round();
  }

  double _safePct(num v) {
    final d = v.toDouble();
    if (d.isNaN || d.isInfinite) return 0.0;
    return d.clamp(0.0, 999.0);
  }
}

// ======== Widgets UI ========

class _HeroCard extends StatelessWidget {
  final double available;
  final double incomes;
  final double expenses;
  const _HeroCard({
    required this.available,
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Mi Control',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Saldo disponible este mes',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: const Color(0xFFE0E7FF)),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCurrency(available),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Ingresos',
                  value: formatCurrency(incomes),
                  icon: Icons.north_east_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroStat(
                  label: 'Gastos',
                  value: formatCurrency(expenses),
                  icon: Icons.north_west_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFFE0E7FF))),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

class _NoticeCard extends StatelessWidget {
  final String text;
  const _NoticeCard({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE0B3), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFF92400E))),
          ),
        ],
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final Color bgFrom;
  final Color bgTo;
  final IconData icon;
  final Color iconBg;
  final Color valueColor;

  const _IndicatorCard({
    required this.title,
    required this.value,
    required this.bgFrom,
    required this.bgTo,
    required this.icon,
    required this.iconBg,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgFrom, bgTo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF475569)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: valueColor,
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

class _BarCard extends StatelessWidget {
  final List<String> keysLabels;
  final List<BarChartGroupData> groups;
  const _BarCard({required this.keysLabels, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 36),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= keysLabels.length)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Transform.rotate(
                      angle: -0.6,
                      child: Text(
                        keysLabels[i],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: groups,
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }
}
