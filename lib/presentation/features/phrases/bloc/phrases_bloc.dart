import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/phrase_datasource.dart';
import '../../../../domain/models/phrase_history_item.dart';
import '../../../../domain/models/quick_phrase.dart';
import '../../../../domain/models/quick_phrase_category.dart';

// --- EVENTOS ---
abstract class PhrasesEvent extends Equatable {
  const PhrasesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPhrases extends PhrasesEvent {
  const LoadPhrases();
}

class RecordSpokenPhrase extends PhrasesEvent {
  final String text;

  const RecordSpokenPhrase(this.text);

  @override
  List<Object?> get props => [text];
}

class AddCustomQuickPhrase extends PhrasesEvent {
  final String text;
  final String iconEmoji;
  final QuickPhraseCategory category;

  const AddCustomQuickPhrase({
    required this.text,
    this.iconEmoji = '💬',
    this.category = QuickPhraseCategory.custom,
  });

  @override
  List<Object?> get props => [text, iconEmoji, category];
}

class DeleteCustomQuickPhrase extends PhrasesEvent {
  final String phraseId;

  const DeleteCustomQuickPhrase(this.phraseId);

  @override
  List<Object?> get props => [phraseId];
}

class ToggleFavoritePhrase extends PhrasesEvent {
  final String text;

  const ToggleFavoritePhrase(this.text);

  @override
  List<Object?> get props => [text];
}

class DeleteHistoryItem extends PhrasesEvent {
  final String id;

  const DeleteHistoryItem(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllHistory extends PhrasesEvent {
  const ClearAllHistory();
}

// --- ESTADO ---
class PhrasesState extends Equatable {
  final List<QuickPhrase> quickPhrases;
  final List<PhraseHistoryItem> history;
  final Set<String> favoriteTexts;
  final bool isLoading;

  const PhrasesState({
    this.quickPhrases = const [],
    this.history = const [],
    this.favoriteTexts = const {},
    this.isLoading = false,
  });

  List<QuickPhrase> get favoriteQuickPhrases =>
      quickPhrases.where((p) => favoriteTexts.contains(p.text)).toList();

  PhrasesState copyWith({
    List<QuickPhrase>? quickPhrases,
    List<PhraseHistoryItem>? history,
    Set<String>? favoriteTexts,
    bool? isLoading,
  }) {
    return PhrasesState(
      quickPhrases: quickPhrases ?? this.quickPhrases,
      history: history ?? this.history,
      favoriteTexts: favoriteTexts ?? this.favoriteTexts,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [quickPhrases, history, favoriteTexts, isLoading];
}

// --- BLOC ---
class PhrasesBloc extends Bloc<PhrasesEvent, PhrasesState> {
  final PhraseDataSource dataSource;

  PhrasesBloc({required this.dataSource}) : super(const PhrasesState()) {
    on<LoadPhrases>(_onLoadPhrases);
    on<RecordSpokenPhrase>(_onRecordSpokenPhrase);
    on<AddCustomQuickPhrase>(_onAddCustomQuickPhrase);
    on<DeleteCustomQuickPhrase>(_onDeleteCustomQuickPhrase);
    on<ToggleFavoritePhrase>(_onToggleFavoritePhrase);
    on<DeleteHistoryItem>(_onDeleteHistoryItem);
    on<ClearAllHistory>(_onClearAllHistory);
  }

  Future<void> _onLoadPhrases(
    LoadPhrases event,
    Emitter<PhrasesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final quickPhrases = await dataSource.getQuickPhrases();
    final history = await dataSource.getPhraseHistory();
    final favorites = await dataSource.getFavoriteTexts();
    emit(state.copyWith(
      quickPhrases: quickPhrases,
      history: history,
      favoriteTexts: favorites,
      isLoading: false,
    ));
  }

  Future<void> _onRecordSpokenPhrase(
    RecordSpokenPhrase event,
    Emitter<PhrasesState> emit,
  ) async {
    final cleanText = event.text.trim();
    if (cleanText.isEmpty) return;

    final isFav = state.favoriteTexts.contains(cleanText);
    final newItem = PhraseHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: cleanText,
      spokenAt: DateTime.now(),
      isFavorite: isFav,
    );

    await dataSource.savePhraseHistoryItem(newItem);
    final updatedHistory = [newItem, ...state.history];
    emit(state.copyWith(history: updatedHistory));
  }

  Future<void> _onAddCustomQuickPhrase(
    AddCustomQuickPhrase event,
    Emitter<PhrasesState> emit,
  ) async {
    final newPhrase = QuickPhrase(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      text: event.text.trim(),
      iconEmoji: event.iconEmoji,
      category: event.category,
      createdAt: DateTime.now(),
    );

    await dataSource.saveCustomQuickPhrase(newPhrase);
    final updatedList = [...state.quickPhrases, newPhrase];
    emit(state.copyWith(quickPhrases: updatedList));
  }

  Future<void> _onDeleteCustomQuickPhrase(
    DeleteCustomQuickPhrase event,
    Emitter<PhrasesState> emit,
  ) async {
    await dataSource.deleteCustomQuickPhrase(event.phraseId);
    final updatedList =
        state.quickPhrases.where((p) => p.id != event.phraseId).toList();
    emit(state.copyWith(quickPhrases: updatedList));
  }

  Future<void> _onToggleFavoritePhrase(
    ToggleFavoritePhrase event,
    Emitter<PhrasesState> emit,
  ) async {
    await dataSource.toggleFavorite(event.text);
    final favorites = await dataSource.getFavoriteTexts();
    final updatedQuick = state.quickPhrases
        .map((p) => p.copyWith(isFavorite: favorites.contains(p.text)))
        .toList();
    final updatedHistory = state.history
        .map((h) => h.copyWith(isFavorite: favorites.contains(h.text)))
        .toList();

    emit(state.copyWith(
      favoriteTexts: favorites,
      quickPhrases: updatedQuick,
      history: updatedHistory,
    ));
  }

  Future<void> _onDeleteHistoryItem(
    DeleteHistoryItem event,
    Emitter<PhrasesState> emit,
  ) async {
    await dataSource.deleteHistoryItem(event.id);
    final updated = state.history.where((h) => h.id != event.id).toList();
    emit(state.copyWith(history: updated));
  }

  Future<void> _onClearAllHistory(
    ClearAllHistory event,
    Emitter<PhrasesState> emit,
  ) async {
    await dataSource.clearHistory();
    emit(state.copyWith(history: []));
  }
}
