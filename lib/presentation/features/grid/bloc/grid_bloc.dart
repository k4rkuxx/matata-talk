import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/default_vocabulary.dart';
import '../../../../domain/models/aac_board.dart';

// Eventos
abstract class GridEvent extends Equatable {
  const GridEvent();
  @override
  List<Object?> get props => [];
}

class LoadBoard extends GridEvent {
  final String boardId;
  const LoadBoard(this.boardId);
  @override
  List<Object?> get props => [boardId];
}

class NavigateHome extends GridEvent {}

class SetHighlightButtonId extends GridEvent {
  final String? buttonId;
  const SetHighlightButtonId(this.buttonId);
  @override
  List<Object?> get props => [buttonId];
}

// Estado
class GridState extends Equatable {
  final AACBoard currentBoard;
  final List<String> navigationHistory;
  final String? highlightedButtonId; // ID del botón que brilla en modo guía

  const GridState({
    required this.currentBoard,
    this.navigationHistory = const [],
    this.highlightedButtonId,
  });

  GridState copyWith({
    AACBoard? currentBoard,
    List<String>? navigationHistory,
    String? highlightedButtonId,
    bool clearHighlight = false,
  }) {
    return GridState(
      currentBoard: currentBoard ?? this.currentBoard,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      highlightedButtonId: clearHighlight
          ? null
          : (highlightedButtonId ?? this.highlightedButtonId),
    );
  }

  @override
  List<Object?> get props =>
      [currentBoard, navigationHistory, highlightedButtonId];
}

// BLoC
class GridBloc extends Bloc<GridEvent, GridState> {
  GridBloc()
      : super(GridState(currentBoard: DefaultVocabulary.getHomeBoard())) {
    on<LoadBoard>(_onLoadBoard);
    on<NavigateHome>(_onNavigateHome);
    on<SetHighlightButtonId>(_onSetHighlight);
  }

  void _onLoadBoard(LoadBoard event, Emitter<GridState> emit) {
    final newBoard = DefaultVocabulary.getBoardById(event.boardId);
    emit(state.copyWith(
      currentBoard: newBoard,
      navigationHistory: [...state.navigationHistory, state.currentBoard.id],
    ));
  }

  void _onNavigateHome(NavigateHome event, Emitter<GridState> emit) {
    emit(state.copyWith(
      currentBoard: DefaultVocabulary.getHomeBoard(),
      navigationHistory: [],
    ));
  }

  void _onSetHighlight(SetHighlightButtonId event, Emitter<GridState> emit) {
    emit(state.copyWith(
      highlightedButtonId: event.buttonId,
      clearHighlight: event.buttonId == null,
    ));
  }
}
