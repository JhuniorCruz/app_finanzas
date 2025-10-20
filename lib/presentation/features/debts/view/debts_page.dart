import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
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
    final pending = vm.items.where((d) => !d.paid).toList();
    final paid = vm.items.where((d) => d.paid).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Deudas')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pending.isEmpty && paid.isEmpty)
                  _emptyBox()
                else ...[
                  if (pending.isNotEmpty) ...[
                    _sectionTitle('Pendientes'),
                    const SizedBox(height: 8),
                    ...pending.map(
                      (d) => _DebtTile(
                        title: d.title,
                        subtitle:
                            'Cuota: ${formatCurrency(d.amount)} • Vence: ${formatDate(d.dueDate)}',
                        isCard: d.creditLimit != null,
                        dpd: _daysPastDue(d.dueDate),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DebtDetailPage(debtId: d.id),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (paid.isNotEmpty) ...[
                    _sectionTitle('Pagadas'),
                    const SizedBox(height: 8),
                    ...paid.map(
                      (d) => _DebtTile(
                        title: d.title,
                        subtitle: 'Cuota: ${formatCurrency(d.amount)} • Pagada',
                        isCard: d.creditLimit != null,
                        dpd: 0,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DebtDetailPage(debtId: d.id),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddDebtPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Agregar deuda'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: Theme.of(context).textTheme.titleMedium);

  Widget _emptyBox() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border, width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Text('Aún no registras deudas.'),
  );

  int _daysPastDue(DateTime due) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(due.year, due.month, due.day)).inDays;
  }
}

class _DebtTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCard;
  final int dpd;
  final VoidCallback onTap;

  const _DebtTile({
    required this.title,
    required this.subtitle,
    required this.isCard,
    required this.dpd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onTime = dpd <= 0;
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
