// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/services/tts_service.dart';
import 'presentation/features/grid/bloc/grid_bloc.dart';
import 'presentation/features/message_bar/bloc/message_bar_bloc.dart';
import 'presentation/features/splash/screens/splash_screen.dart'; // <-- IMPORTANTE

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MessageBarBloc(ttsService: ttsService),
        ),
        BlocProvider(
          create: (_) => GridBloc(),
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
        home: const SplashScreen(), // <-- DEBE SER SplashScreen()
      ),
    );
  }
}
