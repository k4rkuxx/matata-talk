import 'package:flutter/material.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/datasources/default_vocabulary.dart';
import '../../../../domain/services/pathfinder_service.dart';
import '../../../core/widgets/aac_symbol_widget.dart';
import '../../../theme/fitzgerald_colors.dart';

class WordFinderDialog extends StatefulWidget {
  final Function(WordPathResult pathResult) onSelectWordPath;

  const WordFinderDialog({super.key, required this.onSelectWordPath});

  @override
  State<WordFinderDialog> createState() => _WordFinderDialogState();
}

class _WordFinderDialogState extends State<WordFinderDialog> {
  final TextEditingController _searchController = TextEditingController();
  late PathfinderService _pathfinder;
  List<WordPathResult> _results = [];
  static const Color _kPathfinderBlue = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _pathfinder = PathfinderService(boards: DefaultVocabulary.allBoards);
    _loadOfflineBoards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOfflineBoards() async {
    try {
      final boards = await AppDatabase.getAllBoards();
      if (mounted && boards.isNotEmpty) {
        setState(() {
          _pathfinder = PathfinderService(boards: boards);
          if (_searchController.text.isNotEmpty) {
            _results = _pathfinder.searchWords(_searchController.text);
          }
        });
      }
    } catch (_) {}
  }

  void _onSearchChanged(String query) {
    setState(() {
      _results = _pathfinder.searchWords(query);
    });
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
            // ── Cabecera Unificada (Azul Marino Pathfinder) ───────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: _kPathfinderBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buscador Guiado de Palabras',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Encuentra la ruta motora paso a paso',
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

            // ── Barra de Búsqueda ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Escribe una palabra (ej. manzana, correr, feliz)...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.black45),
                  prefixIcon: const Icon(Icons.search, color: _kPathfinderBlue, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF0F4F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),

            // ── Lista de Resultados con Ruta Motora ───────────────────────
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isEmpty
                                  ? Icons.manage_search_rounded
                                  : Icons.search_off_rounded,
                              size: 42,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Escribe arriba para encontrar la ubicación y ruta motora de cualquier pictograma'
                                  : 'No se encontraron palabras para "${_searchController.text}"',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final res = _results[index];
                        final btn = res.targetButton;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: FitzgeraldColors.getColor(btn.partOfSpeech),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Center(
                              child: AACSymbolWidget(
                                assetPath: btn.symbolAssetPath,
                                arasaacId: btn.arasaacId,
                                fallbackEmoji: btn.iconEmoji,
                                size: 26,
                              ),
                            ),
                          ),
                          title: Text(
                            btn.label,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.alt_route_rounded, size: 14, color: _kPathfinderBlue),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  res.pathDescription,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _kPathfinderBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onSelectWordPath(res);
                          },
                        );
                      },
                    ),
            ),

            // ── Divisor ───────────────────────────────────────────────────
            const Divider(height: 1),

            // ── Botón Inferior ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
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
}
