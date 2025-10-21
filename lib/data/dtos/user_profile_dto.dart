// lib/data/dtos/user_profile_dto.dart
import 'package:app_finanzas/domain/entities/user_profile.dart';

//import '../../domain/models.dart'; // <- ajusta si tu UserProfile está en otra ruta

class UserProfileDto {
  final String incomeType; // p.ej. 'mensual'
  final double savingsTarget; // %
  final double debtToIncomeThreshold; // %
  final double utilizationThreshold; // %
  final bool reminders; // recordatorios on/off

  const UserProfileDto({
    required this.incomeType,
    required this.savingsTarget,
    required this.debtToIncomeThreshold,
    required this.utilizationThreshold,
    required this.reminders,
  });

  /// ---- Mapeos DTO <-> dominio ----
  factory UserProfileDto.fromDomain(UserProfile p) => UserProfileDto(
    incomeType: p.incomeType,
    savingsTarget: p.savingsTarget,
    debtToIncomeThreshold: p.debtToIncomeThreshold,
    utilizationThreshold: p.utilizationThreshold,
    reminders: p.reminders,
  );

  UserProfile toDomain() => UserProfile(
    incomeType: incomeType,
    savingsTarget: savingsTarget,
    debtToIncomeThreshold: debtToIncomeThreshold,
    utilizationThreshold: utilizationThreshold,
    reminders: reminders,
  );

  /// ---- Serialización (persistencia) ----
  factory UserProfileDto.fromMap(Map<String, dynamic> map) => UserProfileDto(
    incomeType: (map['incomeType'] as String?) ?? 'mensual',
    savingsTarget: (map['savingsTarget'] as num?)?.toDouble() ?? 10.0,
    debtToIncomeThreshold:
        (map['debtToIncomeThreshold'] as num?)?.toDouble() ?? 40.0,
    utilizationThreshold:
        (map['utilizationThreshold'] as num?)?.toDouble() ?? 50.0,
    reminders: (map['reminders'] as bool?) ?? false,
  );

  Map<String, dynamic> toMap() => {
    'incomeType': incomeType,
    'savingsTarget': savingsTarget,
    'debtToIncomeThreshold': debtToIncomeThreshold,
    'utilizationThreshold': utilizationThreshold,
    'reminders': reminders,
  };
}
