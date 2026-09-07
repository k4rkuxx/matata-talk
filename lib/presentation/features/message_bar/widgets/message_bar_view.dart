import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/message_bar_bloc.dart';

class MessageBarView extends StatelessWidget {
  const MessageBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBarBloc, MessageBarState>(
      builder: (context, state) {
        return Container(
          height: 90,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Lista horizontal de palabras acumuladas
              Expanded(
                child: state.tokens.isEmpty
                    ? const Center(
                        child: Text(
                          'Toca los botones para construir una frase...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.tokens.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final token = state.tokens[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFD0D7DE), width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  token.button.iconEmoji ?? '💬',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                Text(
                                  token.button.label,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF24292F),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(width: 8),

              // Botón de Borrar Última Palabra
              IconButton.filledTonal(
                iconSize: 28,
                icon: const Icon(Icons.backspace_outlined),
                onPressed: state.tokens.isNotEmpty
                    ? () => context
                        .read<MessageBarBloc>()
                        .add(RemoveLastToken())
                    : null,
                tooltip: 'Borrar última palabra',
              ),

              const SizedBox(width: 6),

              // Botón de Borrar Todo
              IconButton.filledTonal(
                iconSize: 28,
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: state.tokens.isNotEmpty
                    ? () => context
                        .read<MessageBarBloc>()
                        .add(ClearAllTokens())
                    : null,
                tooltip: 'Borrar mensaje',
              ),

              const SizedBox(width: 8),

              // Botón Principal de HABLAR (TTS)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), // Verde hablar
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: state.isSpeaking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.volume_up, size: 28),
                label: const Text(
                  'HABLAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: state.tokens.isNotEmpty && !state.isSpeaking
                    ? () => context
                        .read<MessageBarBloc>()
                        .add(SpeakFullMessage())
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
