import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/local/local_storage.dart';
import '../dtos/app_state_dto.dart';
import '../dtos/user_profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final LocalStorage storage;
  ProfileRepositoryImpl(this.storage);

  @override
  Future<UserProfile> getProfile() async {
    final raw = storage.readRaw();
    final state = raw == null
        ? AppStateDto.empty()
        : AppStateDto.fromJsonString(raw);
    final p = state.profile;
    return UserProfile(name: p.name, currency: p.currency);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final raw = storage.readRaw();
    final state = raw == null
        ? AppStateDto.empty()
        : AppStateDto.fromJsonString(raw);

    final updated = AppStateDto(
      transactions: state.transactions,
      debts: state.debts,
      profile: UserProfileDto(name: profile.name, currency: profile.currency),
    );

    await storage.writeRaw(updated.toJsonString());
  }
}
