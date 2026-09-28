import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/datasources/phrase_datasource.dart';
import 'data/datasources/head_pointer_datasource.dart';
import 'data/datasources/scanning_datasource.dart';
import 'data/datasources/settings_datasource.dart';
import 'data/services/tts_service.dart';
import 'presentation/features/grid/bloc/grid_bloc.dart';
import 'presentation/features/message_bar/bloc/message_bar_bloc.dart';
import 'presentation/features/phrases/bloc/phrases_bloc.dart';
import 'presentation/features/head_pointer/bloc/head_pointer_bloc.dart';
import 'presentation/features/scanning/bloc/scanning_bloc.dart';
import 'presentation/features/settings/bloc/touch_settings_bloc.dart';
import 'presentation/features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ttsService = TTSService();
  await ttsService.init();

  runApp(MatataTalkApp(ttsService: ttsService));
}

class MatataTalkApp extends StatelessWidget {
  final TTSService ttsService;

  const MatataTalkApp({super.key, required this.ttsService});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TTSService>.value(value: ttsService),
      ],
      child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MessageBarBloc(ttsService: ttsService),
        ),
        BlocProvider(
          create: (_) => GridBloc(),
        ),
        BlocProvider(
          create: (_) => TouchSettingsBloc(
            dataSource: SharedPreferencesSettingsDataSource(),
          )..add(const LoadTouchSettings()),
        ),
        BlocProvider(
          create: (_) => PhrasesBloc(
            dataSource: SharedPreferencesPhraseDataSource(),
          )..add(const LoadPhrases()),
        ),
        // Motor de Barrido por Conmutadores
        BlocProvider(
          create: (_) => ScanningBloc(
            dataSource: SharedPreferencesScanningDataSource(),
          )..add(const LoadScanningSettings()),
        ),
        // Puntero Facial / Head Tracking
        BlocProvider(
          create: (_) => HeadPointerBloc(
            dataSource: SharedPreferencesHeadPointerDataSource(),
          )..add(const LoadHeadPointerSettings()),
        ),
      ],
      child: MaterialApp(
        title: 'MatataTalk',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.outfitTextTheme(),
        ),
        home: const SplashScreen(),
      ),
    ),
    );
  }
}
