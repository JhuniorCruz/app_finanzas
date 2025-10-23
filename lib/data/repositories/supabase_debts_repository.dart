// lib/data/repositories/supabase_debts_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_finanzas/domain/entities/debt.dart';
import 'package:app_finanzas/domain/repositories/debts_repository.dart';

class SupabaseDebtsRepository implements DebtsRepository {
  final _sb = Supabase.instance.client;

  String get _uid {
    final u = _sb.auth.currentUser;
    if (u == null) throw Exception('No hay sesión');
    return u.id;
  }

  DateTime? _tryParseTs(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  // -------- Row (DB) -> Dominio --------
  Debt _rowToDebt(Map<String, dynamic> r) {
    return Debt(
      id: (r['id'] ?? '').toString(), // lo genera la BD
      title: (r['name'] ?? '').toString(), // DB: name
      amount: (r['amount'] as num).toDouble(),
      dueDate: _tryParseTs(r['due_date']) ?? DateTime.now(),
      paid: (r['paid'] as bool?) ?? false,
      creditLimit: (r['credit_limit'] as num?)?.toDouble(),
      totalDebt: (r['total_debt'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // -------- Dominio -> Row (DB) --------
  Map<String, dynamic> _debtToRow(Debt d) {
    return {
      // NO enviar 'id' en insert; Postgres genera uuid
      'user_id': _uid,
      'name': d.title,
      'amount': d.amount,
      'due_date': d.dueDate.toIso8601String(),
      'paid': d.paid,
      'credit_limit': d.creditLimit,
      'total_debt': d.totalDebt,
    };
  }

  @override
  Future<List<Debt>> list() async {
    final res = await _sb
        .from('debts')
        .select()
        .eq('user_id', _uid)
        .order('created_at', ascending: false);

    return (res as List).cast<Map<String, dynamic>>().map(_rowToDebt).toList();
  }

  @override
  Future<void> add(Debt d) async {
    await _sb.from('debts').insert(_debtToRow(d));
  }

  // Firma que exige la interfaz: solo id
  @override
  Future<void> markPaid(String id) async {
    await _sb
        .from('debts')
        .update({'paid': true, 'paid_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', _uid);
  }

  @override
  Future<void> clearAll() async {
    await _sb.from('debts').delete().eq('user_id', _uid);
  }

  // (Opcional) si luego quieres poder desmarcar:
  // Future<void> setPaid(String id, bool paid) async { ... }
}
