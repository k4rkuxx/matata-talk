import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../data/datasources/board_local_datasource.dart';
import '../../../../domain/models/aac_board.dart';
import '../../../../domain/services/open_board_service.dart';
import '../../grid/bloc/grid_bloc.dart';

class OpenBoardDialog extends StatefulWidget {
  final AACBoard currentBoard;

  const OpenBoardDialog({super.key, required this.currentBoard});

  @override
  State<OpenBoardDialog> createState() => _OpenBoardDialogState();
}

class _OpenBoardDialogState extends State<OpenBoardDialog> {
  bool _isLoading = false;
  String? _statusMessage;
  static const Color _kIndigo = Color(0xFF1565C0);

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
            // ── Cabecera Unificada (Índigo) ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: _kIndigo,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync_alt, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interoperabilidad (OBF / OBZ)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Importar y exportar tableros abiertos estándar',
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

            // ── Contenido Deslizable ──────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'El estándar Open Board Format permite compartir e importar tableros compatibles con cualquier comunicador CAA.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 12),
                      if (_statusMessage != null)
                        Text(
                          _statusMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                    ] else ...[
                      _buildOptionCard(
                        icon: Icons.file_upload_outlined,
                        title: 'Exportar Tablero Actual (.obf)',
                        subtitle: 'Exporta "${widget.currentBoard.name}" como archivo .obf individual.',
                        buttonLabel: 'Exportar OBF',
                        onPressed: _exportCurrentBoardObf,
                      ),
                      const SizedBox(height: 10),
                      _buildOptionCard(
                        icon: Icons.archive_outlined,
                        title: 'Exportar Colección Completa (.obz)',
                        subtitle: 'Empaqueta todos los tableros en un archivo comprimido .obz.',
                        buttonLabel: 'Exportar OBZ',
                        onPressed: _exportAllBoardsObz,
                      ),
                      const SizedBox(height: 10),
                      _buildOptionCard(
                        icon: Icons.file_download_outlined,
                        title: 'Importar Archivo (.obf / .obz)',
                        subtitle: 'Carga tableros creados en MatataTalk u otras apps CAA.',
                        buttonLabel: 'Seleccionar Archivo',
                        isPrimary: true,
                        onPressed: _importFile,
                      ),
                    ],
                  ],
                ),
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
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? const Color(0xFF90CAF9) : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isPrimary ? _kIndigo : Colors.black54, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? _kIndigo : Colors.white,
              foregroundColor: isPrimary ? Colors.white : _kIndigo,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCurrentBoardObf() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generando archivo .obf...';
    });

    try {
      final jsonStr = OpenBoardService.exportBoardToObfJson(widget.currentBoard);
      final bytes = utf8.encode(jsonStr);
      final fileName = '${widget.currentBoard.name.replaceAll(' ', '_')}.obf';

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: fileName,
              mimeType: 'application/json',
            ),
          ],
          text: 'Tablero OBF: ${widget.currentBoard.name}',
        ),
      );
    } catch (e) {
      _showSnackbar('Error al exportar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportAllBoardsObz() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Empaquetando tableros en .obz...';
    });

    try {
      final repo = LocalVocabularyRepository();
      final allBoards = await repo.getAllBoards();
      final obzBytes = OpenBoardService.exportBoardsToObzBytes(allBoards, rootBoardId: 'home_board');

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              obzBytes,
              name: 'MatataTalk_Vocabulario.obz',
              mimeType: 'application/zip',
            ),
          ],
          text: 'Paquete de Tableros MatataTalk (.obz)',
        ),
      );
    } catch (e) {
      _showSnackbar('Error al exportar paquete: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['obf', 'obz', 'json', 'zip'],
      );

      if (file == null) return;

      setState(() {
        _isLoading = true;
        _statusMessage = 'Leyendo ${file.name}...';
      });

      final fileBytes = await file.readAsBytes();
      final repo = LocalVocabularyRepository();
      final nameLower = file.name.toLowerCase();

      if (nameLower.endsWith('.obz') || nameLower.endsWith('.zip')) {
        final package = OpenBoardService.importFromObzBytes(fileBytes);
        await repo.saveAllBoards(package.boards);

        if (mounted) {
          context.read<GridBloc>().add(LoadBoard(package.rootBoardId));
          Navigator.of(context).pop();
          _showGlobalSnackbar(
            '¡Paquete .obz importado! Se cargaron ${package.boards.length} tableros.',
          );
        }
      } else {
        // Archivo individual .obf / .json
        final jsonStr = utf8.decode(fileBytes);
        final board = OpenBoardService.importFromObfJson(jsonStr);
        await repo.saveBoard(board);

        if (mounted) {
          context.read<GridBloc>().add(LoadBoard(board.id));
          Navigator.of(context).pop();
          _showGlobalSnackbar(
            '¡Tablero "${board.name}" importado con éxito (${board.buttons.length} botones)!',
          );
        }
      }
    } catch (e) {
      _showSnackbar('Error al importar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : _kIndigo,
      ),
    );
  }

  void _showGlobalSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }
}
