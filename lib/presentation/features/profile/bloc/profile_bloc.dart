import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/profile_repository.dart';

// --- EVENTOS ---
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfiles extends ProfileEvent {
  const LoadProfiles();
}

class SwitchProfile extends ProfileEvent {
  final String profileId;

  const SwitchProfile(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

class CreateProfile extends ProfileEvent {
  final String name;
  final String avatarEmoji;
  final String notes;
  final String rootBoardId;

  const CreateProfile({
    required this.name,
    this.avatarEmoji = '🧒',
    this.notes = '',
    this.rootBoardId = 'home_board',
  });

  @override
  List<Object?> get props => [name, avatarEmoji, notes, rootBoardId];
}

class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DeleteProfileEvent extends ProfileEvent {
  final String profileId;

  const DeleteProfileEvent(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

// --- ESTADO ---
class ProfileState extends Equatable {
  final List<UserProfile> profiles;
  final UserProfile? activeProfile;
  final bool isLoading;
  final String? message;

  const ProfileState({
    this.profiles = const [],
    this.activeProfile,
    this.isLoading = false,
    this.message,
  });

  ProfileState copyWith({
    List<UserProfile>? profiles,
    UserProfile? activeProfile,
    bool? isLoading,
    String? message,
  }) {
    return ProfileState(
      profiles: profiles ?? this.profiles,
      activeProfile: activeProfile ?? this.activeProfile,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }

  @override
  List<Object?> get props => [profiles, activeProfile, isLoading, message];
}

// --- BLOC ---
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(const ProfileState()) {
    on<LoadProfiles>(_onLoadProfiles);
    on<SwitchProfile>(_onSwitchProfile);
    on<CreateProfile>(_onCreateProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<DeleteProfileEvent>(_onDeleteProfile);
  }

  Future<void> _onLoadProfiles(
    LoadProfiles event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final list = await repository.getAllProfiles();
      final activeId = await repository.getActiveProfileId();
      final active = list.firstWhere(
        (p) => p.id == activeId,
        orElse: () => list.isNotEmpty ? list.first : UserProfile.defaultProfile(),
      );

      emit(state.copyWith(
        profiles: list,
        activeProfile: active,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        message: 'Error al cargar perfiles: $e',
      ));
    }
  }

  Future<void> _onSwitchProfile(
    SwitchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final target = state.profiles.firstWhere((p) => p.id == event.profileId);
      await repository.setActiveProfileId(target.id);
      emit(state.copyWith(
        activeProfile: target,
        message: 'Perfil activo: "${target.name}"',
      ));
    } catch (_) {}
  }

  Future<void> _onCreateProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final now = DateTime.now();
      // Si hay un perfil activo, copiamos sus ajustes de accesibilidad como base cómoda
      final baseTouch = state.activeProfile?.touchSettings;
      final baseScan = state.activeProfile?.scanningSettings;
      final baseHp = state.activeProfile?.headPointerSettings;

      final newProf = UserProfile(
        id: 'profile_${now.millisecondsSinceEpoch}',
        name: event.name.trim(),
        avatarEmoji: event.avatarEmoji,
        rootBoardId: event.rootBoardId,
        notes: event.notes.trim(),
        touchSettings: baseTouch ?? UserProfile.defaultProfile().touchSettings,
        scanningSettings: baseScan ?? UserProfile.defaultProfile().scanningSettings,
        headPointerSettings: baseHp ?? UserProfile.defaultProfile().headPointerSettings,
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveProfile(newProf);
      await repository.setActiveProfileId(newProf.id);

      final updated = [...state.profiles, newProf];
      emit(state.copyWith(
        profiles: updated,
        activeProfile: newProf,
        message: 'Perfil "${newProf.name}" creado y activado',
      ));
    } catch (e) {
      emit(state.copyWith(message: 'Error al crear perfil: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final updatedProf = event.profile.copyWith(updatedAt: DateTime.now());
      await repository.saveProfile(updatedProf);

      final list = state.profiles.map((p) => p.id == updatedProf.id ? updatedProf : p).toList();
      final active = state.activeProfile?.id == updatedProf.id ? updatedProf : state.activeProfile;

      emit(state.copyWith(
        profiles: list,
        activeProfile: active,
        message: 'Perfil actualizado',
      ));
    } catch (_) {}
  }

  Future<void> _onDeleteProfile(
    DeleteProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state.profiles.length <= 1) {
        emit(state.copyWith(message: 'No puedes eliminar el único perfil disponible.'));
        return;
      }

      final success = await repository.deleteProfile(event.profileId);
      if (success) {
        final remaining = state.profiles.where((p) => p.id != event.profileId).toList();
        UserProfile newActive = state.activeProfile!;
        if (state.activeProfile?.id == event.profileId) {
          newActive = remaining.first;
          await repository.setActiveProfileId(newActive.id);
        }

        emit(state.copyWith(
          profiles: remaining,
          activeProfile: newActive,
          message: 'Perfil eliminado',
        ));
      }
    } catch (_) {}
  }
}
