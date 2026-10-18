import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../database/app_database.dart';

class LocalProfileRepository implements ProfileRepository {
  @override
  Future<List<UserProfile>> getAllProfiles() async {
    return await AppDatabase.getAllProfiles();
  }

  @override
  Future<UserProfile?> getProfile(String id) async {
    return await AppDatabase.getProfile(id);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await AppDatabase.saveProfile(profile);
  }

  @override
  Future<bool> deleteProfile(String id) async {
    return await AppDatabase.deleteProfile(id);
  }

  @override
  Future<String> getActiveProfileId() async {
    return await AppDatabase.getActiveProfileId();
  }

  @override
  Future<void> setActiveProfileId(String id) async {
    await AppDatabase.setActiveProfileId(id);
  }
}
