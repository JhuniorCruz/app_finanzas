import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/scoring.dart';
import '../../debts/controller/debts_controller.dart';
import 'add_debt_page.dart';
import 'debt_detail_page.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});
  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() => context.read<DebtsController>().load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DebtsController>();
    final items = vm.items;

    final pending = items.where((d) => !d.paid).toList();
    final paid = items.where((d) => d.paid).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(
            onAdd: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AddDebtPage()));
            },
          ),
          const SizedBox(height: 16),

          // ---- Pendientes ----
          Text('Pendientes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          if (vm.loading)
            const _LoadingCard()
          else if (pending.isEmpty)
            const _EmptyState()
          else
            ...pending.map((d) {
              final dpd = d.paid ? 0 : getDaysPastDue(d.dueDate);
              final onTime = dpd <= 0;
              final isCard = d.creditLimit != null;
              final title = d.title; // <- en el original era "name"

              return _DebtCard(
                isCard: isCard,
                title: title,
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

          if (pending.isNotEmpty) const SizedBox(height: 16),

          // ---- Pagadas ----
          if (paid.isNotEmpty) ...[
            Text('Pagadas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...paid.map((d) {
              final isCard = d.creditLimit != null;
              final title = d.title;
              return _DebtCard(
                isCard: isCard,
                title: title,
                subtitle: 'Cuota: ${formatCurrency(d.amount)} • Pagada',
                onTime: true,
                dpd: 0,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DebtDetailPage(debtId: d.id),
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// =================== UI widgets (idénticos al original) ===================

class _Header extends StatelessWidget {
  final VoidCallback onAdd;
  const _Header({required this.onAdd});

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
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
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
            onPressed: onAdd,
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

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
    final pillBg = onTime ? const Color(0xFFEFFDF5) : const Color(0xFFFFEBEE);
    final pillFg = onTime ? const Color(0xFF047857) : const Color(0xFFB91C1C);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isCard
                  ? const Color(0xFFE0ECFF)
                  : const Color(0xFFFDE68A),
              child: Icon(
                isCard ? Icons.credit_card : Icons.account_balance,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                onTime ? 'A tiempo' : 'DPD: $dpd',
                style: TextStyle(
                  color: pillFg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
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

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
