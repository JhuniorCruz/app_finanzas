// lib/data/dtos/app_state_dto.dart
import 'dart:convert';

import 'transaction_dto.dart';
import 'debt_dto.dart';
import 'user_profile_dto.dart';

/// Snapshot serializable de todo el estado de la app.
class AppStateDto {
  final List<TransactionDto> transactions;
  final List<DebtDto> debts;
  final UserProfileDto? profile;

  const AppStateDto({
    required this.transactions,
    required this.debts,
    required this.profile,
  });

  factory AppStateDto.empty() =>
      const AppStateDto(transactions: [], debts: [], profile: null);

  /// Construye desde un JSON en String (persistencia).
  factory AppStateDto.fromJsonString(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;

    return AppStateDto(
      transactions: (map['transactions'] as List<dynamic>? ?? [])
          .map((e) => TransactionDto.fromMap(e as Map<String, dynamic>))
          .toList(),
      debts: (map['debts'] as List<dynamic>? ?? [])
          .map((e) => DebtDto.fromMap(e as Map<String, dynamic>))
          .toList(),
      profile: map['profile'] == null
          ? null
          : UserProfileDto.fromMap(map['profile'] as Map<String, dynamic>),
    );
  }

  /// Serializa a JSON en String (persistencia).
  String toJsonString() => jsonEncode({
    'transactions': transactions.map((e) => e.toMap()).toList(),
    'debts': debts.map((e) => e.toMap()).toList(),
    'profile': profile?.toMap(),
  });
}
