import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<List<UserProfile>> getAllProfiles();
  Future<UserProfile?> getProfile(String id);
  Future<void> saveProfile(UserProfile profile);
  Future<bool> deleteProfile(String id);
  Future<String> getActiveProfileId();
  Future<void> setActiveProfileId(String id);
}
