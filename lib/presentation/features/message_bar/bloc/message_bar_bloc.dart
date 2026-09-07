import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/tts_service.dart';
import '../../../../domain/models/aac_button.dart';
import '../../../../domain/models/message_token.dart';

// Eventos
abstract class MessageBarEvent extends Equatable {
  const MessageBarEvent();
  @override
  List<Object?> get props => [];
}

class AddButtonToMessage extends MessageBarEvent {
  final AACButton button;
  const AddButtonToMessage(this.button);
  @override
  List<Object?> get props => [button];
}

class RemoveLastToken extends MessageBarEvent {}

class ClearAllTokens extends MessageBarEvent {}

class SpeakFullMessage extends MessageBarEvent {}

// Estado
class MessageBarState extends Equatable {
  final List<MessageToken> tokens;
  final bool isSpeaking;

  const MessageBarState({
    this.tokens = const [],
    this.isSpeaking = false,
  });

  String get fullText =>
      tokens.map((t) => t.button.textToSpeak).join(' ');

  MessageBarState copyWith({
    List<MessageToken>? tokens,
    bool? isSpeaking,
  }) {
    return MessageBarState(
      tokens: tokens ?? this.tokens,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  @override
  List<Object?> get props => [tokens, isSpeaking];
}

// BLoC
class MessageBarBloc extends Bloc<MessageBarEvent, MessageBarState> {
  final TTSService ttsService;

  MessageBarBloc({required this.ttsService}) : super(const MessageBarState()) {
    on<AddButtonToMessage>(_onAddButton);
    on<RemoveLastToken>(_onRemoveLastToken);
    on<ClearAllTokens>(_onClearAll);
    on<SpeakFullMessage>(_onSpeakFull);
  }

  void _onAddButton(AddButtonToMessage event, Emitter<MessageBarState> emit) {
    // 1. Habla la palabra individual al tocarla
    ttsService.speak(event.button.textToSpeak);

    // 2. La añade a la barra de frase
    final newToken = MessageToken(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      button: event.button,
    );
    emit(state.copyWith(tokens: [...state.tokens, newToken]));
  }

  void _onRemoveLastToken(RemoveLastToken event, Emitter<MessageBarState> emit) {
    if (state.tokens.isNotEmpty) {
      final updated = List<MessageToken>.from(state.tokens)..removeLast();
      emit(state.copyWith(tokens: updated));
    }
  }

  void _onClearAll(ClearAllTokens event, Emitter<MessageBarState> emit) {
    emit(state.copyWith(tokens: []));
  }

  Future<void> _onSpeakFull(
      SpeakFullMessage event, Emitter<MessageBarState> emit) async {
    if (state.tokens.isEmpty) return;
    emit(state.copyWith(isSpeaking: true));
    await ttsService.speak(state.fullText);
    emit(state.copyWith(isSpeaking: false));
  }
}
