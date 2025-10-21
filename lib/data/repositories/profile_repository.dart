import 'package:app_finanzas/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();
  Future<void> updateProfile(UserProfile profile);
}
