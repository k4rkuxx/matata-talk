import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/settings_datasource.dart';
import '../../../../domain/models/touch_settings.dart';

// --- EVENTOS ---
abstract class TouchSettingsEvent extends Equatable {
  const TouchSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTouchSettings extends TouchSettingsEvent {
  const LoadTouchSettings();
}

class UpdateTouchSettings extends TouchSettingsEvent {
  final TouchSettings settings;

  const UpdateTouchSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ResetTouchSettings extends TouchSettingsEvent {
  const ResetTouchSettings();
}

// --- ESTADOS ---
class TouchSettingsState extends Equatable {
  final TouchSettings settings;
  final bool isLoaded;

  const TouchSettingsState({
    required this.settings,
    this.isLoaded = false,
  });

  TouchSettingsState copyWith({
    TouchSettings? settings,
    bool? isLoaded,
  }) {
    return TouchSettingsState(
      settings: settings ?? this.settings,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [settings, isLoaded];
}

// --- BLOC ---
class TouchSettingsBloc
    extends Bloc<TouchSettingsEvent, TouchSettingsState> {
  final SettingsDataSource dataSource;

  TouchSettingsBloc({required this.dataSource})
      : super(TouchSettingsState(settings: TouchSettings.standard())) {
    on<LoadTouchSettings>(_onLoadSettings);
    on<UpdateTouchSettings>(_onUpdateSettings);
    on<ResetTouchSettings>(_onResetSettings);
  }

  Future<void> _onLoadSettings(
    LoadTouchSettings event,
    Emitter<TouchSettingsState> emit,
  ) async {
    final settings = await dataSource.getTouchSettings();
    emit(TouchSettingsState(settings: settings, isLoaded: true));
  }

  Future<void> _onUpdateSettings(
    UpdateTouchSettings event,
    Emitter<TouchSettingsState> emit,
  ) async {
    emit(state.copyWith(settings: event.settings));
    await dataSource.saveTouchSettings(event.settings);
  }

  Future<void> _onResetSettings(
    ResetTouchSettings event,
    Emitter<TouchSettingsState> emit,
  ) async {
    final standard = TouchSettings.standard();
    emit(state.copyWith(settings: standard));
    await dataSource.saveTouchSettings(standard);
  }
}
