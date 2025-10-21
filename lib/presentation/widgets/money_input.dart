import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_finanzas/core/theme/app_theme.dart';

class MoneyInput extends StatelessWidget {
  final String label; // título encima del campo
  final TextEditingController controller;
  final String? errorText;
  final bool autofocus;

  const MoneyInput({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: AppColors.foreground);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: labelStyle),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
          ],
          style: const TextStyle(
            color: AppColors.foreground,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.primary,
          decoration: const InputDecoration(
            hintText: '0,00',
            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
            prefixText: 'S/ ',
            prefixStyle: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(errorText: errorText),
        ),
      ],
    );
  }
}
