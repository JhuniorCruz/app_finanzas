// lib/data/repositories/supabase_profile_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

// ⬇️ Usa el import que tengas para tu entidad.
// Si tu clase se llama distinto o el archivo es otro, cambia esta línea.
import 'package:app_finanzas/domain/entities/user_profile.dart';
// import 'package:app_finanzas/domain/entities/profile.dart' as alt; // <- ejemplo

import 'package:app_finanzas/domain/repositories/profile_repository.dart';

/// Implementación remota de ProfileRepository usando Supabase.
class SupabaseProfileRepository implements ProfileRepository {
  final _sb = Supabase.instance.client;

  String get _uid {
    final u = _sb.auth.currentUser;
    if (u == null) throw Exception('No hay sesión de usuario.');
    return u.id;
  }

  // --------- Mapping fila <-> entidad ---------

  UserProfile _rowToDomain(Map<String, dynamic> r) {
    return UserProfile(
      incomeType: (r['income_type'] as String?) ?? 'mensual',
      savingsTarget: (r['savings_target'] as num?)?.toDouble() ?? 10.0,
      debtToIncomeThreshold:
          (r['debt_to_income_threshold'] as num?)?.toDouble() ?? 40.0,
      utilizationThreshold:
          (r['utilization_threshold'] as num?)?.toDouble() ?? 50.0,
      reminders: (r['reminders'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> _domainToRow(UserProfile p) {
    return <String, dynamic>{
      'id': _uid, // la PK es el uid del usuario
      'income_type': p.incomeType,
      'savings_target': p.savingsTarget,
      'debt_to_income_threshold': p.debtToIncomeThreshold,
      'utilization_threshold': p.utilizationThreshold,
      'reminders': p.reminders,
    };
  }

  Map<String, dynamic> _defaultRow() => <String, dynamic>{
    'id': _uid,
    'income_type': 'mensual',
    'savings_target': 10.0,
    'debt_to_income_threshold': 40.0,
    'utilization_threshold': 50.0,
    'reminders': false,
  };

  // --------- Implementación de la interfaz ---------

  /// La interfaz espera `Future<UserProfile>` (no-nullable),
  /// por lo que si no existe fila, creamos una con defaults y la devolvemos.
  @override
  Future<UserProfile> getProfile() async {
    final row = await _sb
        .from('profiles')
        .select()
        .eq('id', _uid)
        .maybeSingle();

    if (row == null) {
      final defaults = _defaultRow();
      await _sb.from('profiles').insert(defaults);
      return _rowToDomain(defaults);
    }

    return _rowToDomain(Map<String, dynamic>.from(row));
  }

  /// Guarda/actualiza el perfil del usuario.
  /// Usamos `upsert` con `onConflict: 'id'` para crear si no existe.
  @override
  Future<void> updateProfile(UserProfile profile) async {
    await _sb.from('profiles').upsert(_domainToRow(profile), onConflict: 'id');
  }
}
