import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_finanzas/core/theme/app_theme.dart';
import 'package:app_finanzas/core/utils/formatters.dart';
import 'package:app_finanzas/presentation/widgets/money_input.dart';
import 'package:app_finanzas/presentation/widgets/category_chip.dart';
import 'package:app_finanzas/presentation/features/transactions/controller/transactions_controller.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});
  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _Cat {
  final String id, label;
  final IconData icon;
  const _Cat(this.id, this.label, this.icon);
}

class _AddExpensePageState extends State<AddExpensePage> {
  String? category;
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: formatDate(DateTime.now()));
  final noteCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

  static const List<_Cat> _cats = [
    _Cat('comida', 'Comida', Icons.restaurant),
    _Cat('transporte', 'Transporte', Icons.directions_bus),
    _Cat('vivienda', 'Vivienda', Icons.home_rounded),
    _Cat('salud', 'Salud', Icons.local_hospital_rounded),
    _Cat('educacion', 'Educación', Icons.school_rounded),
    _Cat('otros', 'Otros', Icons.category_rounded),
  ];

  @override
  void dispose() {
    amountCtrl.dispose();
    dateCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar gasto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Categorías (chips) =====
          Text('Categoría', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cats
                .map(
                  (c) => CategoryChip(
                    label: c.label,
                    icon: c.icon,
                    selected: category == c.id,
                    onTap: () => setState(() => category = c.id),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          // ===== Card de campos =====
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                MoneyInput(label: 'Monto', controller: amountCtrl),
                const SizedBox(height: 12),

                // Selector de fecha con aspecto de input
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        dateCtrl.text = formatDate(picked);
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Text(dateCtrl.text),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100), // margen para que no tape el botón
        ],
      ),

      // ===== Botón Guardar (fijo) =====
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
              onPressed: () async {
                final amt = parseMoney(amountCtrl.text);
                if (amt <= 0 || category == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completa categoría y monto válido'),
                    ),
                  );
                  return;
                }
                await context.read<TransactionsController>().addExpense(
                  category: category!,
                  amount: amt,
                  date: selectedDate,
                  note: noteCtrl.text.trim().isEmpty
                      ? null
                      : noteCtrl.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ),
        ),
      ),
    );
  }
}
