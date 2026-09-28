import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/head_pointer_datasource.dart';
import '../../../../domain/models/head_pointer_settings.dart';

// --- EVENTOS ---
abstract class HeadPointerEvent extends Equatable {
  const HeadPointerEvent();

  @override
  List<Object?> get props => [];
}

class LoadHeadPointerSettings extends HeadPointerEvent {
  const LoadHeadPointerSettings();
}

class UpdateHeadPointerSettings extends HeadPointerEvent {
  final HeadPointerSettings settings;

  const UpdateHeadPointerSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleHeadPointerEnabled extends HeadPointerEvent {
  const ToggleHeadPointerEnabled();
}

// --- ESTADO ---
class HeadPointerState extends Equatable {
  final HeadPointerSettings settings;
  final bool isLoaded;

  const HeadPointerState({
    required this.settings,
    this.isLoaded = false,
  });

  HeadPointerState copyWith({
    HeadPointerSettings? settings,
    bool? isLoaded,
  }) {
    return HeadPointerState(
      settings: settings ?? this.settings,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [settings, isLoaded];
}

// --- BLOC ---
class HeadPointerBloc extends Bloc<HeadPointerEvent, HeadPointerState> {
  final HeadPointerDataSource dataSource;

  HeadPointerBloc({required this.dataSource})
      : super(HeadPointerState(settings: HeadPointerSettings.standard())) {
    on<LoadHeadPointerSettings>(_onLoadSettings);
    on<UpdateHeadPointerSettings>(_onUpdateSettings);
    on<ToggleHeadPointerEnabled>(_onToggleEnabled);
  }

  Future<void> _onLoadSettings(
    LoadHeadPointerSettings event,
    Emitter<HeadPointerState> emit,
  ) async {
    final settings = await dataSource.getSettings();
    emit(HeadPointerState(settings: settings, isLoaded: true));
  }

  Future<void> _onUpdateSettings(
    UpdateHeadPointerSettings event,
    Emitter<HeadPointerState> emit,
  ) async {
    emit(state.copyWith(settings: event.settings));
    await dataSource.saveSettings(event.settings);
  }

  Future<void> _onToggleEnabled(
    ToggleHeadPointerEnabled event,
    Emitter<HeadPointerState> emit,
  ) async {
    final updated = state.settings.copyWith(enabled: !state.settings.enabled);
    emit(state.copyWith(settings: updated));
    await dataSource.saveSettings(updated);
  }
}
