// profile_repository.dart
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile(UserProfile profile);
}
