import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/scanning_datasource.dart';
import '../../../../domain/models/scanning_settings.dart';

// --- EVENTOS ---
abstract class ScanningEvent extends Equatable {
  const ScanningEvent();

  @override
  List<Object?> get props => [];
}

class LoadScanningSettings extends ScanningEvent {
  const LoadScanningSettings();
}

class UpdateScanningSettings extends ScanningEvent {
  final ScanningSettings settings;

  const UpdateScanningSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ResetScanningSettings extends ScanningEvent {
  const ResetScanningSettings();
}

// --- ESTADO ---
class ScanningState extends Equatable {
  final ScanningSettings settings;
  final bool isLoaded;

  const ScanningState({
    required this.settings,
    this.isLoaded = false,
  });

  ScanningState copyWith({
    ScanningSettings? settings,
    bool? isLoaded,
  }) {
    return ScanningState(
      settings: settings ?? this.settings,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [settings, isLoaded];
}

// --- BLOC ---
class ScanningBloc extends Bloc<ScanningEvent, ScanningState> {
  final ScanningDataSource dataSource;

  ScanningBloc({required this.dataSource})
      : super(ScanningState(settings: ScanningSettings.standard())) {
    on<LoadScanningSettings>(_onLoadSettings);
    on<UpdateScanningSettings>(_onUpdateSettings);
    on<ResetScanningSettings>(_onResetSettings);
  }

  Future<void> _onLoadSettings(
    LoadScanningSettings event,
    Emitter<ScanningState> emit,
  ) async {
    final settings = await dataSource.getScanningSettings();
    emit(ScanningState(settings: settings, isLoaded: true));
  }

  Future<void> _onUpdateSettings(
    UpdateScanningSettings event,
    Emitter<ScanningState> emit,
  ) async {
    emit(state.copyWith(settings: event.settings));
    await dataSource.saveScanningSettings(event.settings);
  }

  Future<void> _onResetSettings(
    ResetScanningSettings event,
    Emitter<ScanningState> emit,
  ) async {
    final standard = ScanningSettings.standard();
    emit(state.copyWith(settings: standard));
    await dataSource.saveScanningSettings(standard);
  }
}
