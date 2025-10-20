import 'package:flutter/material.dart';
import 'package:app_finanzas/core/theme/app_theme.dart';

enum KpiStatus { good, warning, danger }

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final KpiStatus status;
  final IconData icon;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    this.onTap,
  });

  LinearGradient _bg(KpiStatus s) {
    switch (s) {
      case KpiStatus.good:
        return const LinearGradient(
          colors: [AppColors.kpiGoodFrom, AppColors.kpiGoodTo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case KpiStatus.warning:
        return const LinearGradient(
          colors: [AppColors.kpiWarnFrom, AppColors.kpiWarnTo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case KpiStatus.danger:
        return const LinearGradient(
          colors: [AppColors.kpiDangerFrom, AppColors.kpiDangerTo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _valueColor(KpiStatus s) => {
    KpiStatus.good: const Color(0xFF047857), // emerald-700
    KpiStatus.warning: const Color(0xFF92400E), // amber-700
    KpiStatus.danger: const Color(0xFFB91C1C), // red-700
  }[s]!;

  Color _iconColor(KpiStatus s) => {
    KpiStatus.good: const Color(0xFF059669), // emerald-600
    KpiStatus.warning: const Color(0xFFD97706), // amber-600
    KpiStatus.danger: const Color(0xFFDC2626), // red-600
  }[s]!;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    final card = Container(
      constraints: const BoxConstraints(minHeight: 86),
      decoration: BoxDecoration(
        gradient: _bg(status),
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x14000000),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Texto
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _valueColor(status),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Chip circular para icono
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: _iconColor(status)),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    // ⬇︎ ENVOLVEMOS CON MATERIAL + INKWELL PARA QUE EL TAP FUNCIONE SIEMPRE
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias, // recorta el splash al borde redondeado
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: card),
    );
  }
}
