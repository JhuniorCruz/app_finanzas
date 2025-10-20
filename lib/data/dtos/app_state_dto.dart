import 'dart:convert';

import 'transaction_dto.dart';
import 'debt_dto.dart';
import 'user_profile_dto.dart';

class AppStateDto {
  final List<TransactionDto> transactions;
  final List<DebtDto> debts;
  final UserProfileDto profile;

  AppStateDto({
    required this.transactions,
    required this.debts,
    required this.profile,
  });

  factory AppStateDto.empty() => AppStateDto(
    transactions: const [],
    debts: const [],
    profile: const UserProfileDto(name: '', currency: 'PEN'),
  );

  factory AppStateDto.fromJsonString(String raw) {
    final map = json.decode(raw) as Map<String, dynamic>;
    return AppStateDto(
      transactions: (map['transactions'] as List? ?? [])
          .map((e) => TransactionDto.fromMap(e))
          .toList(),
      debts: (map['debts'] as List? ?? [])
          .map((e) => DebtDto.fromMap(e))
          .toList(),
      profile: UserProfileDto.fromMap(map['profile'] ?? {}),
    );
  }

  String toJsonString() {
    final map = {
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'debts': debts.map((d) => d.toMap()).toList(),
      'profile': profile.toMap(),
    };
    return json.encode(map);
  }
}
