import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_finanzas/domain/entities/transaction.dart' as dom;
import 'package:app_finanzas/domain/repositories/transactions_repository.dart';

class SupabaseTransactionsRepository implements TransactionsRepository {
  final _sb = Supabase.instance.client;

  String get _uid {
    final u = _sb.auth.currentUser;
    if (u == null) throw Exception('No hay sesión');
    return u.id;
  }

  DateTime _parseTs(dynamic v) {
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.parse(v);
    return DateTime.now();
  }

  // ---------- Row (DB) -> Dominio ----------
  dom.FinanceTx _rowToTransaction(Map<String, dynamic> r) {
    return dom.FinanceTx(
      id: (r['id'] ?? '').toString(),
      type: (r['type'] ?? 'expense') as String, // 'income' | 'expense'
      amount: (r['amount'] as num).toDouble(), // guardado positivo en DB
      category: (r['category'] as String?) ?? '',
      date: _parseTs(r['date'] ?? r['created_at']),
      note: r['note'] as String?,
    );
  }

  // ---------- Dominio -> Row (DB) ----------
  Map<String, dynamic> _toRow(dom.FinanceTx t) {
    return {
      'user_id': _uid,
      'type': t.type,
      'amount': t.amount.abs(), // <- evita violar CHECK(amount > 0)
      'category': t.category,
      'date': t.date.toIso8601String(),
      'note': t.note,
    }..removeWhere((_, v) => v == null);
  }

  @override
  Future<List<dom.FinanceTx>> list() async {
    final res = await _sb
        .from('transactions')
        .select()
        .eq('user_id', _uid)
        .order('date', ascending: false);

    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(_rowToTransaction).toList();
  }

  @override
  Future<void> add(dom.FinanceTx t) async {
    try {
      await _sb.from('transactions').insert(_toRow(t));
    } on PostgrestException catch (e) {
      // 23514 = check_violation
      if (e.code == '23514') {
        throw Exception('El monto debe ser mayor que 0.');
      }
      rethrow;
    }
  }

  @override
  Future<void> remove(String id) async {
    await _sb.from('transactions').delete().eq('user_id', _uid).eq('id', id);
  }

  @override
  Future<void> clearAll() async {
    await _sb.from('transactions').delete().eq('user_id', _uid);
  }
}
