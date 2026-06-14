import 'package:flutter/material.dart';
import 'package:app_finanzas/core/theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final void Function(int) onTap;

  const BottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.home_rounded, 'Inicio'),
      (Icons.account_balance_wallet_rounded, 'Deudas'),
      (Icons.chat_bubble_outline_rounded, 'Asesor'),
      (Icons.calculate_rounded, 'Simular'),
      (Icons.settings_rounded, 'Ajustes'),
    ];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Color(0x14000000))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (i) {
          final active = i == index;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withOpacity(0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: active ? 1.10 : 1.0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      items[i].$1,
                      size: 20,
                      color: active
                          ? AppColors.primary
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].$2,
                    style: TextStyle(
                      fontSize: 12,
                      color: active
                          ? AppColors.primary
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
