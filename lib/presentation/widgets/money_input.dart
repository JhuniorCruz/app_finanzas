import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Ajusta la ruta según tu estructura. Si este archivo está en lib/presentation/widgets/:
import 'package:app_finanzas/core/theme/app_theme.dart';

class MoneyInput extends StatelessWidget {
  final String label; // título encima del campo
  final TextEditingController controller;
  final String? errorText; // para errores manuales (opcional)
  final bool autofocus;

  // NUEVO: validación para usar dentro de <Form>
  final FormFieldValidator<String>? validator;

  // Opcionales útiles
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const MoneyInput({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.autofocus = false,
    this.validator, // <-- nuevo
    this.textInputAction,
    this.focusNode,
    this.onChanged,
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
        TextFormField(
          // <-- TextFormField para soportar validator
          controller: controller,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          inputFormatters: [
            // Permite dígitos, punto y coma (para locales con coma)
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
          ],
          style: const TextStyle(
            color: AppColors.foreground, // color del texto ingresado
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: '0,00',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixText: 'S/ ',
            prefixStyle: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
            errorText: errorText, // si usas validator, normalmente déjalo null
            border: const OutlineInputBorder(),
          ),
          validator: validator, // <-- nuevo
          textInputAction: textInputAction,
          focusNode: focusNode,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
