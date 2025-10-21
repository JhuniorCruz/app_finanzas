import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../controller/debts_controller.dart';
import 'debt_detail_page.dart';

class DebtsPage extends StatelessWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DebtsController>();
    final pending = vm.items.where((d) => !d.paid).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(),
          const SizedBox(height: 16),
          Text('Pendientes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          if (pending.isEmpty)
            const _EmptyState()
          else
            ...pending.map((d) {
              final dpd = d.paid ? 0 : getDaysPastDue(d.dueDate);
              final onTime = dpd <= 0;
              final isCard = d.creditLimit != null; // deducimos tipo por límite

              return _DebtCard(
                isCard: isCard,
                title: d.title,
                subtitle:
                    'Cuota: ${formatCurrency(d.amount)} • Vence: ${formatDate(d.dueDate)}',
                onTime: onTime,
                dpd: dpd,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DebtDetailPage(debtId: d.id),
                  ),
                ),
              );
            }),

          const SizedBox(height: 16),
          const _InfoTip(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ====== header ======
class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C6BF6), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis deudas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gestiona tus pagos y vencimientos',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () => Navigator.of(context).pushNamed('/addDebt'),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ====== card ======
class _DebtCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCard;
  final bool onTime;
  final int dpd;
  final VoidCallback onTap;

  const _DebtCard({
    required this.title,
    required this.subtitle,
    required this.isCard,
    required this.onTime,
    required this.dpd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = onTime
        ? const Color(0xFF86EFAC)
        : const Color(0xFFFCA5A5);
    final bgPill = onTime ? const Color(0xFFEFFDF5) : const Color(0xFFFFEBEE);
    final fgPill = onTime ? const Color(0xFF047857) : const Color(0xFFB91C1C);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (onTime
                    ? const Color(0xFFE6FFFA)
                    : const Color(0xFFFFF5F5)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCard
                    ? Icons.credit_card_rounded
                    : Icons.account_balance_rounded,
                color: onTime
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bgPill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      onTime ? '✓ Al día' : '⚠ DPD $dpd',
                      style: TextStyle(
                        color: fgPill,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== tip y empty ======
class _InfoTip extends StatelessWidget {
  const _InfoTip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'DPD = Días de atraso desde la fecha de vencimiento. Mantener DPD en 0 es fundamental para tu puntaje educativo.',
        style: TextStyle(color: Color(0xFF475569)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text('No tienes deudas pendientes.')),
    );
  }
}
