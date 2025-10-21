import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../widgets/money_input.dart';
import '../../../widgets/category_chip.dart';
import '../controller/transactions_controller.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});
  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

// Modelo tipado para evitar casts
class _Cat {
  final String id;
  final String label;
  final IconData icon;
  const _Cat(this.id, this.label, this.icon);
}

class _AddExpensePageState extends State<AddExpensePage> {
  String? category;
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: formatDate(DateTime.now()));
  final noteCtrl = TextEditingController();

  bool amountError = false;
  DateTime selectedDate = DateTime.now();

  // Lista tipada de categorías
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
          Text('Categoría', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),

          // Chips de categoría
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in _cats)
                CategoryChip(
                  label: c.label,
                  icon: c.icon,
                  selected: category == c.id,
                  onTap: () => setState(() => category = c.id),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Monto con prefijo "S/"
          MoneyInput(
            label: 'Monto',
            controller: amountCtrl,
            errorText: amountError ? 'Ingresa un monto válido' : null,
          ),

          const SizedBox(height: 12),

          Text('Fecha', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: dateCtrl,
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'dd/mm/aaaa',
              suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
            ),
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
                  dateCtrl.text = formatDate(picked); // resistente a locales
                });
              }
            },
          ),

          const SizedBox(height: 12),

          Text(
            'Nota (opcional)',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(
              hintText: 'Escribe un detalle si lo necesitas',
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                try {
                  if (category == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecciona una categoría')),
                    );
                    return;
                  }

                  final amount = parseCurrency(amountCtrl.text);
                  if (amount <= 0.0) {
                    setState(() => amountError = true);
                    return;
                  } else {
                    if (amountError) setState(() => amountError = false);
                  }

                  final date = selectedDate; // sincronizado con dateCtrl

                  context.read<TransactionsController>().addExpense(
                    category: category!,
                    amount: amount,
                    date: date,
                    note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
                  );

                  Navigator.pop(context);
                } catch (e) {
                  // No permitir que la app se caiga en emulador/dispositivo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo guardar: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
