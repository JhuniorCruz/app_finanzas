// lib/domain/entities/user_profile.dart
import 'dart:convert';

class UserProfile {
  /// Tipo de ingreso preferido para la UI (solo informativo)
  /// valores esperados: 'recibo' | 'planilla'
  final String incomeType;

  /// Meta de ahorro (% 0–100)
  final double savingsTarget;

  /// Umbral recomendado de Deuda/Ingreso (% 0–100)
  final double debtToIncomeThreshold;

  /// Umbral recomendado de Utilización de crédito (% 0–100)
  final double utilizationThreshold;

  /// Preferencia de recordatorios (la lógica puede no estar implementada aún)
  final bool reminders;

  const UserProfile({
    required this.incomeType,
    required this.savingsTarget,
    required this.debtToIncomeThreshold,
    required this.utilizationThreshold,
    required this.reminders,
  });

  /// Perfil inicial por defecto (coincide con el original)
  factory UserProfile.initial() => const UserProfile(
    incomeType: 'recibo',
    savingsTarget: 10.0, // 10%
    debtToIncomeThreshold: 40.0, // 40%
    utilizationThreshold: 50.0, // 50%
    reminders: false,
  );

  UserProfile copyWith({
    String? incomeType,
    double? savingsTarget,
    double? debtToIncomeThreshold,
    double? utilizationThreshold,
    bool? reminders,
  }) {
    return UserProfile(
      incomeType: incomeType ?? this.incomeType,
      savingsTarget: savingsTarget ?? this.savingsTarget,
      debtToIncomeThreshold:
          debtToIncomeThreshold ?? this.debtToIncomeThreshold,
      utilizationThreshold: utilizationThreshold ?? this.utilizationThreshold,
      reminders: reminders ?? this.reminders,
    );
  }

  Map<String, dynamic> toMap() => {
    'incomeType': incomeType,
    'savingsTarget': savingsTarget,
    'debtToIncomeThreshold': debtToIncomeThreshold,
    'utilizationThreshold': utilizationThreshold,
    'reminders': reminders,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Soporta claves alternativas por si ya tenías persistencia con otros nombres
    double _d(Map m, String k, double def) =>
        (m[k] is num) ? (m[k] as num).toDouble() : def;

    return UserProfile(
      incomeType: (map['incomeType'] as String?) ?? 'recibo',
      savingsTarget: _d(
        map,
        'savingsTarget',
        _d(map, 'savings_goal', 10.0),
      ), // fallback a 'savings_goal'
      debtToIncomeThreshold: _d(
        map,
        'debtToIncomeThreshold',
        _d(map, 'dtiThreshold', 40.0),
      ), // fallback a 'dtiThreshold'
      utilizationThreshold: _d(
        map,
        'utilizationThreshold',
        _d(map, 'utilizationWarning', 50.0),
      ), // fallback
      reminders: (map['reminders'] as bool?) ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
