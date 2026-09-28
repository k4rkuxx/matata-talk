import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _pathfinder = PathfinderService(boards: DefaultVocabulary.allBoards);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _results = _pathfinder.searchWords(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 520),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cabecera del Buscador
            Row(
              children: [
                const Icon(
                  Icons.travel_explore_rounded,
                  color: Color(0xFF1976D2),
                  size: 26,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Buscador Guiado de Palabras',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Campo de Búsqueda
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Escribe una palabra (ej. manzana, correr, pelota)...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF0F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Lista de Resultados con su ruta motora
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Escribe arriba para encontrar la ruta de cualquier pictograma'
                            : 'No se encontraron palabras para "${_searchController.text}"',
                        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final res = _results[index];
                        final btn = res.targetButton;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: FitzgeraldColors.getColor(btn.partOfSpeech),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: AACSymbolWidget(
                                assetPath: btn.symbolAssetPath,
                                arasaacId: btn.arasaacId,
                                fallbackEmoji: btn.iconEmoji,
                                size: 28,
                              ),
                            ),
                          ),
                          title: Text(
                            btn.label,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.alt_route_rounded, size: 14, color: Color(0xFF1976D2)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  res.pathDescription,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onSelectWordPath(res);
                          },
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
