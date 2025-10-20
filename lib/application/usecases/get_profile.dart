import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repo;
  GetProfile(this.repo);
  Future<UserProfile> call() => repo.getProfile();
}
