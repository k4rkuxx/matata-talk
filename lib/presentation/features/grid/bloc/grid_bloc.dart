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

// Estado
class GridState extends Equatable {
  final AACBoard currentBoard;
  final List<String> navigationHistory;

  const GridState({
    required this.currentBoard,
    this.navigationHistory = const [],
  });

  GridState copyWith({
    AACBoard? currentBoard,
    List<String>? navigationHistory,
  }) {
    return GridState(
      currentBoard: currentBoard ?? this.currentBoard,
      navigationHistory: navigationHistory ?? this.navigationHistory,
    );
  }

  @override
  List<Object?> get props => [currentBoard, navigationHistory];
}

// BLoC
class GridBloc extends Bloc<GridEvent, GridState> {
  GridBloc()
      : super(GridState(currentBoard: DefaultVocabulary.getHomeBoard())) {
    on<LoadBoard>(_onLoadBoard);
    on<NavigateHome>(_onNavigateHome);
  }

  void _onLoadBoard(LoadBoard event, Emitter<GridState> emit) {
    AACBoard newBoard;
    if (event.boardId == DefaultVocabulary.foodBoardId) {
      newBoard = DefaultVocabulary.getFoodBoard();
    } else {
      newBoard = DefaultVocabulary.getHomeBoard();
    }

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
}
