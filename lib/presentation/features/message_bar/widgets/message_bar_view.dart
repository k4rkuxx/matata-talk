import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/aac_symbol_widget.dart';
import '../../../theme/fitzgerald_colors.dart';
import '../bloc/message_bar_bloc.dart';

class MessageBarView extends StatelessWidget {
  const MessageBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBarBloc, MessageBarState>(
      builder: (context, state) {
        final hasTokens = state.tokens.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Instrucción superior fija
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 2),
              child: Row(
                children: [
                  Icon(
                    hasTokens
                        ? Icons.record_voice_over_rounded
                        : Icons.touch_app_outlined,
                    size: 16,
                    color: const Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasTokens
                          ? 'Frase en construcción (presiona HABLAR para escucharla):'
                          : 'Toca los pictogramas abajo para construir tu frase',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1565C0),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Bandeja de Mensaje Principal (100% ancho disponible para pictogramas)
            Container(
              height: 92,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasTokens
                      ? const Color(0xFF1976D2).withValues(alpha: 0.5)
                      : const Color(0xFFCFD8DC),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: !hasTokens
                  ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFECEFF1),
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                              color: Color(0xFF90A4AE),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bandeja de frase vacía',
                                  style: TextStyle(
                                    color: Color(0xFF546E7A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Toca los pictogramas abajo para construir tu frase',
                                  style: TextStyle(
                                    color: Color(0xFF90A4AE),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.tokens.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final token = state.tokens[index];
                        final btn = token.button;
                        final bgColor =
                            FitzgeraldColors.getColor(btn.partOfSpeech);

                        return Container(
                          width: 75,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: bgColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: bgColor,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: AACSymbolWidget(
                                    assetPath: btn.symbolAssetPath,
                                    arasaacId: btn.arasaacId,
                                    fallbackEmoji: btn.iconEmoji,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Expanded(
                                flex: 2,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    btn.label,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // 3. Fila de Botones de Acción (Separados abajo para no competir por ancho)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
              child: Row(
                children: [
                  // Botón Borrar Última Palabra
                  IconButton.filledTonal(
                    iconSize: 20,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFECEFF1),
                      foregroundColor: const Color(0xFF455A64),
                      minimumSize: const Size(42, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.backspace_outlined),
                    onPressed: hasTokens
                        ? () => context
                            .read<MessageBarBloc>()
                            .add(RemoveLastToken())
                        : null,
                    tooltip: 'Borrar última palabra',
                  ),

                  const SizedBox(width: 8),

                  // Botón Borrar Todo
                  IconButton.filledTonal(
                    iconSize: 20,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      foregroundColor: const Color(0xFFC62828),
                      minimumSize: const Size(42, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: hasTokens
                        ? () =>
                            context.read<MessageBarBloc>().add(ClearAllTokens())
                        : null,
                    tooltip: 'Borrar todo el mensaje',
                  ),

                  const SizedBox(width: 8),

                  // Botón Principal HABLAR (Amplio y accesible)
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        minimumSize: const Size.fromHeight(38),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: state.isSpeaking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.volume_up, size: 22),
                      label: const Text(
                        'HABLAR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      onPressed: hasTokens && !state.isSpeaking
                          ? () => context
                              .read<MessageBarBloc>()
                              .add(SpeakFullMessage())
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
