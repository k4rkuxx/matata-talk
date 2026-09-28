import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/aac_button.dart';
import '../../../../domain/models/button_action.dart';
import '../../../../domain/models/part_of_speech.dart';
import '../../../../domain/services/pathfinder_service.dart';
import '../../grammar_popup/widgets/morphology_popup_dialog.dart';
import '../../grid/bloc/grid_bloc.dart';
import '../../grid/widgets/motor_grid_view.dart';
import '../../message_bar/bloc/message_bar_bloc.dart';
import '../../message_bar/widgets/message_bar_view.dart';
import '../../phrases/bloc/phrases_bloc.dart';
import '../../phrases/widgets/quick_phrases_dialog.dart';
import '../../settings/widgets/touch_accessibility_dialog.dart';
import '../../word_finder/widgets/word_finder_dialog.dart';

class CommunicatorScreen extends StatefulWidget {
  const CommunicatorScreen({super.key});

  @override
  State<CommunicatorScreen> createState() => _CommunicatorScreenState();
}

class _CommunicatorScreenState extends State<CommunicatorScreen> {
  List<WordPathStep>? _activePathSteps;
  int _currentStepIndex = 0;

  void _handleButtonTap(BuildContext context, AACButton button) {
    // Si estamos en modo guía (Pathfinder), avanzar al siguiente paso
    if (_activePathSteps != null && _activePathSteps!.isNotEmpty) {
      final expectedStep = _activePathSteps![_currentStepIndex];
      if (button.id == expectedStep.targetButton.id) {
        _currentStepIndex++;
        if (_currentStepIndex < _activePathSteps!.length) {
          final nextStep = _activePathSteps![_currentStepIndex];
          context.read<GridBloc>().add(SetHighlightButtonId(nextStep.targetButton.id));
        } else {
          // Ruta completada con éxito
          _clearPathfinder(context);
        }
      }
    }

    switch (button.actionType) {
      case ButtonActionType.speakAndAddToMessage:
        context.read<MessageBarBloc>().add(AddButtonToMessage(button));
        break;
      case ButtonActionType.navigateToBoard:
        if (button.targetBoardId != null) {
          context.read<GridBloc>().add(LoadBoard(button.targetBoardId!));
        }
        break;
      case ButtonActionType.backToHome:
        context.read<GridBloc>().add(NavigateHome());
        break;
      case ButtonActionType.clearMessage:
        context.read<MessageBarBloc>().add(ClearAllTokens());
        break;
      case ButtonActionType.deleteLastToken:
        context.read<MessageBarBloc>().add(RemoveLastToken());
        break;
      case ButtonActionType.grammarPopup:
        _handleButtonLongPress(context, button);
        break;
    }
  }

  void _startPathfinderGuide(WordPathResult result) {
    setState(() {
      _activePathSteps = result.steps;
      _currentStepIndex = 0;
    });

    // 1. Ir al tablero inicial del primer paso
    context.read<GridBloc>().add(NavigateHome());

    // 2. Resaltar el primer botón
    final firstStep = result.steps[0];
    context.read<GridBloc>().add(SetHighlightButtonId(firstStep.targetButton.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ruta: ${result.pathDescription}'),
        backgroundColor: const Color(0xFF1976D2),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _clearPathfinder(BuildContext context) {
    setState(() {
      _activePathSteps = null;
      _currentStepIndex = 0;
    });
    context.read<GridBloc>().add(const SetHighlightButtonId(null));
  }

  void _handleButtonLongPress(BuildContext context, AACButton button) {
    if (button.partOfSpeech == PartOfSpeech.verb ||
        button.partOfSpeech == PartOfSpeech.noun ||
        button.partOfSpeech == PartOfSpeech.adjective) {
      showDialog(
        context: context,
        builder: (dialogContext) => MorphologyPopupDialog(
          button: button,
          onSelectInflection: (inflectedButton) {
            context
                .read<MessageBarBloc>()
                .add(AddButtonToMessage(inflectedButton));
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessageBarBloc, MessageBarState>(
      listenWhen: (previous, current) =>
          !previous.isSpeaking && current.isSpeaking && current.tokens.isNotEmpty,
      listener: (context, state) {
        // Registrar automáticamente la frase en el historial cuando se reproduce
        context.read<PhrasesBloc>().add(RecordSpokenPhrase(state.fullText));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECEFF1),
        appBar: AppBar(
          titleSpacing: 12,
          title: BlocBuilder<GridBloc, GridState>(
            builder: (context, state) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MatataTalk',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        state.currentBoard.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xFF1565C0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            // Botón de Frases Rápidas e Historial
            IconButton(
              icon: const Icon(Icons.forum_outlined, size: 24),
              tooltip: 'Frases Rápidas e Historial',
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dContext) => QuickPhrasesDialog(
                    ttsService: context.read<MessageBarBloc>().ttsService,
                  ),
                );
              },
            ),
            // Botón del Buscador Guiado
            IconButton(
              icon: const Icon(Icons.search, size: 24),
              tooltip: 'Buscar pictograma',
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dContext) => WordFinderDialog(
                    onSelectWordPath: (pathResult) =>
                        _startPathfinderGuide(pathResult),
                  ),
                );
              },
            ),
            // Botón de Filtros Táctiles y Accesibilidad
            IconButton(
              icon: const Icon(Icons.touch_app_outlined, size: 24),
              tooltip: 'Filtros Táctiles y Accesibilidad',
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dContext) => const TouchAccessibilityDialog(),
                );
              },
            ),
            // Botón de Inicio
            IconButton(
              icon: const Icon(Icons.home_outlined, size: 24),
              tooltip: 'Ir a Inicio',
              padding: const EdgeInsets.only(left: 6, right: 12),
              constraints: const BoxConstraints(),
              onPressed: () {
                _clearPathfinder(context);
                context.read<GridBloc>().add(NavigateHome());
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const MessageBarView(),
              Expanded(
                child: BlocBuilder<GridBloc, GridState>(
                  builder: (context, state) {
                    return MotorGridView(
                      board: state.currentBoard,
                      highlightedButtonId: state.highlightedButtonId,
                      onButtonTap: (button) => _handleButtonTap(context, button),
                      onButtonLongPress: (button) =>
                          _handleButtonLongPress(context, button),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
