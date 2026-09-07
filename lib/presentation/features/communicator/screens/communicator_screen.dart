import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/aac_button.dart';
import '../../../../domain/models/button_action.dart';
import '../../grid/bloc/grid_bloc.dart';
import '../../grid/widgets/motor_grid_view.dart';
import '../../message_bar/bloc/message_bar_bloc.dart';
import '../../message_bar/widgets/message_bar_view.dart';

class CommunicatorScreen extends StatelessWidget {
  const CommunicatorScreen({super.key});

  void _handleButtonTap(BuildContext context, AACButton button) {
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
        // Se implementará en la siguiente fase
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: BlocBuilder<GridBloc, GridState>(
          builder: (context, state) {
            return Row(
              children: [
                const Text(
                  'MatataTalk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    state.currentBoard.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Colors.white70,
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Ir a Inicio',
            onPressed: () => context.read<GridBloc>().add(NavigateHome()),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () {
              // Configuración de perfiles y accesibilidad
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra de Mensajes y Reproducción de Voz
            const MessageBarView(),

            // 2. Cuadrícula de Comunicación con Memoria Motora
            Expanded(
              child: BlocBuilder<GridBloc, GridState>(
                builder: (context, state) {
                  return MotorGridView(
                    board: state.currentBoard,
                    onButtonTap: (button) => _handleButtonTap(context, button),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
