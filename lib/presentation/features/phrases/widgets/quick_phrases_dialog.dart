import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/tts_service.dart';
import '../../../../domain/models/phrase_history_item.dart';
import '../../../../domain/models/quick_phrase.dart';
import '../../../../domain/models/quick_phrase_category.dart';
import '../bloc/phrases_bloc.dart';

class QuickPhrasesDialog extends StatefulWidget {
  final TTSService ttsService;
  final Function(String text)? onPhraseSelected;

  const QuickPhrasesDialog({
    super.key,
    required this.ttsService,
    this.onPhraseSelected,
  });

  @override
  State<QuickPhrasesDialog> createState() => _QuickPhrasesDialogState();
}

class _QuickPhrasesDialogState extends State<QuickPhrasesDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  QuickPhraseCategory? _selectedCategory;
  static const Color _kThemeBlue = Color(0xFF0288D1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<PhrasesBloc>().add(const LoadPhrases());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _speakPhrase(String text) {
    widget.ttsService.speak(text);
    context.read<PhrasesBloc>().add(RecordSpokenPhrase(text));

    if (widget.onPhraseSelected != null) {
      widget.onPhraseSelected!(text);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hablando: "$text"',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: _kThemeBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddCustomPhraseDialog() {
    final textController = TextEditingController();
    String selectedEmoji = '💬';
    QuickPhraseCategory selectedCategory = QuickPhraseCategory.custom;

    final emojis = ['💬', '❤️', '🍎', '💧', '🚗', '🎮', '🧸', '🛑', '✨', '👋', '🚽', '🛌'];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.add_comment_rounded, color: _kThemeBlue),
              SizedBox(width: 8),
              Text('Nueva Frase Rápida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Texto de la frase',
                    hintText: 'Ej. Quiero escuchar música',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Selecciona un icono:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: emojis.map((e) {
                    final isSelected = selectedEmoji == e;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedEmoji = e),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFB3E5FC) : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? _kThemeBlue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text('Categoría:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<QuickPhraseCategory>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: QuickPhraseCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text('${cat.emoji} ${cat.displayName}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _kThemeBlue),
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  context.read<PhrasesBloc>().add(AddCustomQuickPhrase(
                        text: textController.text.trim(),
                        iconEmoji: selectedEmoji,
                        category: selectedCategory,
                      ));
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: screenHeight * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Cabecera Unificada (Celeste Azulado / Cyan Blue) ───────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: _kThemeBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.forum_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Frases Rápidas e Historial',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Comunicación inmediata y registro de frases',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Pestañas Estilizadas ─────────────────────────────────────
            Container(
              color: const Color(0xFFF5F9FC),
              child: TabBar(
                controller: _tabController,
                labelColor: _kThemeBlue,
                unselectedLabelColor: Colors.black54,
                indicatorColor: _kThemeBlue,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.flash_on_rounded, size: 18), text: 'Frases'),
                  Tab(icon: Icon(Icons.star_rounded, size: 18), text: 'Favoritas'),
                  Tab(icon: Icon(Icons.history_rounded, size: 18), text: 'Historial'),
                ],
              ),
            ),

            // ── Contenido Deslizable por Pestañas ─────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPhrasesTab(),
                    _buildFavoritesTab(),
                    _buildHistoryTab(),
                  ],
                ),
              ),
            ),

            // ── Divisor ───────────────────────────────────────────────────
            const Divider(height: 1),

            // ── Barra de Acciones Inferior ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_comment_rounded, size: 16),
                    label: const Text('Nueva Frase'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kThemeBlue,
                      side: const BorderSide(color: _kThemeBlue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _showAddCustomPhraseDialog,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PESTAÑA 1: FRASES RÁPIDAS ---
  Widget _buildPhrasesTab() {
    return BlocBuilder<PhrasesBloc, PhrasesState>(
      builder: (context, state) {
        final phrases = _selectedCategory == null
            ? state.quickPhrases
            : state.quickPhrases.where((p) => p.category == _selectedCategory).toList();

        return Column(
          children: [
            // Filtros por Categoría
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todas', null),
                  ...QuickPhraseCategory.values.map(
                    (cat) => _buildFilterChip('${cat.emoji} ${cat.displayName}', cat),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Lista de Frases
            Expanded(
              child: phrases.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay frases en esta categoría',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: phrases.length,
                      itemBuilder: (context, index) {
                        return _buildPhraseCard(phrases[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // --- PESTAÑA 2: FAVORITAS ---
  Widget _buildFavoritesTab() {
    return BlocBuilder<PhrasesBloc, PhrasesState>(
      builder: (context, state) {
        final favorites = state.favoriteQuickPhrases;

        if (favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_outline_rounded, size: 42, color: Colors.grey),
                SizedBox(height: 6),
                Text(
                  'No tienes frases favoritas guardadas',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'Toca la estrella ⭐ en cualquier frase para verla aquí',
                  style: TextStyle(color: Colors.black54, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            return _buildPhraseCard(favorites[index]);
          },
        );
      },
    );
  }

  // --- PESTAÑA 3: HISTORIAL ---
  Widget _buildHistoryTab() {
    return BlocBuilder<PhrasesBloc, PhrasesState>(
      builder: (context, state) {
        if (state.history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 42, color: Colors.grey),
                SizedBox(height: 6),
                Text(
                  'Aún no hay frases habladas',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'Las frases habladas se registrarán aquí automáticamente',
                  style: TextStyle(color: Colors.black54, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Últimas frases habladas (${state.history.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 15),
                  label: const Text('Borrar Todo', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    context.read<PhrasesBloc>().add(const ClearAllHistory());
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                itemCount: state.history.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = state.history[index];
                  return _buildHistoryItemTile(item);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhraseCard(QuickPhrase phrase) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 3),
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(phrase.iconEmoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          phrase.text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1E1E1E),
          ),
        ),
        subtitle: Text(
          phrase.category.displayName,
          style: TextStyle(
            fontSize: 10,
            color: Colors.blueGrey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                phrase.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: phrase.isFavorite ? const Color(0xFFFFB300) : Colors.grey,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Guardar en Favoritas',
              onPressed: () {
                context.read<PhrasesBloc>().add(ToggleFavoritePhrase(phrase.text));
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: _kThemeBlue, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Hablar frase',
              onPressed: () => _speakPhrase(phrase.text),
            ),
          ],
        ),
        onTap: () => _speakPhrase(phrase.text),
      ),
    );
  }

  Widget _buildHistoryItemTile(PhraseHistoryItem item) {
    final timeStr = _formatTimestamp(item.spokenAt);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      leading: const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFFE8F5E9),
        child: Icon(Icons.record_voice_over_rounded, color: Color(0xFF2E7D32), size: 16),
      ),
      title: Text(
        item.text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      subtitle: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: item.isFavorite ? const Color(0xFFFFB300) : Colors.grey,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              context.read<PhrasesBloc>().add(ToggleFavoritePhrase(item.text));
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: _kThemeBlue, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _speakPhrase(item.text),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              context.read<PhrasesBloc>().add(DeleteHistoryItem(item.id));
            },
          ),
        ],
      ),
      onTap: () => _speakPhrase(item.text),
    );
  }

  Widget _buildFilterChip(String label, QuickPhraseCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSelected,
        selectedColor: const Color(0xFFB3E5FC),
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Hace un momento';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} h';
    } else {
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
