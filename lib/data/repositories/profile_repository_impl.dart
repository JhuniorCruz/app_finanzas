import 'package:app_finanzas/data/datasources/local/local_storage.dart';
import 'package:app_finanzas/data/dtos/app_state_dto.dart';
import 'package:app_finanzas/data/dtos/user_profile_dto.dart';
import 'package:app_finanzas/domain/entities/user_profile.dart';
import 'package:app_finanzas/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final LocalStorage storage;
  ProfileRepositoryImpl(this.storage);

  // ⬇️ Interfaz no-nula → devolvemos SIEMPRE un UserProfile
  @override
  Future<UserProfile> getProfile() async {
    // si readRaw() es async, usa: final raw = await storage.readRaw();
    final raw = storage.readRaw();
    final state = raw == null
        ? AppStateDto.empty()
        : AppStateDto.fromJsonString(raw);

    final p = state.profile;
    if (p != null) {
      return UserProfile(
        incomeType: p.incomeType,
        savingsTarget: p.savingsTarget,
        debtToIncomeThreshold: p.debtToIncomeThreshold,
        utilizationThreshold: p.utilizationThreshold,
        reminders: p.reminders,
      );
    }

    // Perfil por defecto cuando aún no hay datos persistidos
    return UserProfile(
      incomeType: 'mensual',
      savingsTarget: 10,
      debtToIncomeThreshold: 40,
      utilizationThreshold: 50,
      reminders: false,
    );
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final raw = storage.readRaw(); // si es async: await storage.readRaw()
    final state = raw == null
        ? AppStateDto.empty()
        : AppStateDto.fromJsonString(raw);

    final updated = AppStateDto(
      transactions: state.transactions,
      debts: state.debts,
      profile: UserProfileDto(
        incomeType: profile.incomeType,
        savingsTarget: profile.savingsTarget,
        debtToIncomeThreshold: profile.debtToIncomeThreshold,
        utilizationThreshold: profile.utilizationThreshold,
        reminders: profile.reminders,
      ),
    );

    await storage.writeRaw(updated.toJsonString());
  }
}
