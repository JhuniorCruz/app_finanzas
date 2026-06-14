import 'package:flutter/material.dart';

class QuickPrompts extends StatelessWidget {
  final Function(String) onPromptSelected;

  const QuickPrompts({super.key, required this.onPromptSelected});

  @override
  Widget build(BuildContext context) {
    final prompts = [
      "Analiza mi situación actual",
      "¿Cómo reduzco mis deudas?",
      "Recomendaciones de ahorro",
      "¿En qué invertir mi dinero?",
    ];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              label: Text(
                prompt,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onPressed: () => onPromptSelected(prompt),
            ),
          );
        },
      ),
    );
  }
}
