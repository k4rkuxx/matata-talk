import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../data/datasources/board_local_datasource.dart';
import '../../../../data/datasources/head_pointer_datasource.dart';
import '../../../../data/datasources/phrase_datasource.dart';
import '../../../../data/datasources/profile_datasource.dart';
import '../../../../data/datasources/scanning_datasource.dart';
import '../../../../data/datasources/settings_datasource.dart';
import '../../../../domain/models/backup_data.dart';
import '../../../../domain/services/backup_restore_service.dart';
import '../../grid/bloc/grid_bloc.dart';
import '../../head_pointer/bloc/head_pointer_bloc.dart';
import '../../phrases/bloc/phrases_bloc.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../scanning/bloc/scanning_bloc.dart';
import '../bloc/touch_settings_bloc.dart';

class BackupRestoreDialog extends StatefulWidget {
  const BackupRestoreDialog({super.key});

  static const Color _kTeal = Color(0xFF00796B);

  @override
  State<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends State<BackupRestoreDialog> {
  bool _isLoading = false;
  String? _statusMessage;
  BackupData? _pendingBackupData;
  bool _overwriteExisting = true;

  late final BackupRestoreService _backupService;

  @override
  void initState() {
    super.initState();
    _backupService = BackupRestoreService(
      vocabularyRepository: LocalVocabularyRepository(),
      profileRepository: LocalProfileRepository(),
      phraseDataSource: SharedPreferencesPhraseDataSource(),
      settingsDataSource: SharedPreferencesSettingsDataSource(),
      scanningDataSource: SharedPreferencesScanningDataSource(),
      headPointerDataSource: SharedPreferencesHeadPointerDataSource(),
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
            // ── Cabecera Unificada (Teal Clínico) ────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: BackupRestoreDialog._kTeal,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Copia de Seguridad y Restauración',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Respaldo integral de perfiles, tableros y frases (.matata)',
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
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Cuerpo de Opciones ───────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(color: BackupRestoreDialog._kTeal),
                        ),
                      ),
                      if (_statusMessage != null)
                        Center(
                          child: Text(
                            _statusMessage!,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                    ] else if (_pendingBackupData != null) ...[
                      // ── Vista Previa del Respaldo Seleccionado ────────────
                      _buildPreviewCard(_pendingBackupData!),
                    ] else ...[
                      const Text(
                        'Protege la información del usuario ante cambios de tableta o pérdida de datos. Puedes guardar o restaurar la copia en Google Drive, WhatsApp o la memoria del equipo.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 14),
                      _buildOptionCard(
                        icon: Icons.upload_file_rounded,
                        title: 'Crear Copia de Seguridad (.matata)',
                        subtitle: 'Empaqueta todos los perfiles clínicos, tableros, frases frecuentes y ajustes de acceso.',
                        buttonLabel: 'Crear Copia',
                        onPressed: _exportFullBackup,
                      ),
                      const SizedBox(height: 12),
                      _buildOptionCard(
                        icon: Icons.settings_backup_restore_rounded,
                        title: 'Restaurar Copia de Seguridad',
                        subtitle: 'Carga un archivo .matata o .zip para recuperar los datos en este dispositivo.',
                        buttonLabel: 'Seleccionar Archivo',
                        isPrimary: true,
                        onPressed: _pickAndInspectBackupFile,
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
        color: isPrimary ? const Color(0xFFE0F2F1) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? const Color(0xFF80CBC4) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isPrimary ? BackupRestoreDialog._kTeal : Colors.black54, size: 28),
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
              backgroundColor: isPrimary ? BackupRestoreDialog._kTeal : Colors.white,
              foregroundColor: isPrimary ? Colors.white : BackupRestoreDialog._kTeal,
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

  Widget _buildPreviewCard(BackupData data) {
    final m = data.manifest;
    final dateStr = '${m.createdAt.day.toString().padLeft(2, '0')}/${m.createdAt.month.toString().padLeft(2, '0')}/${m.createdAt.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF80CBC4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined, color: BackupRestoreDialog._kTeal, size: 20),
              SizedBox(width: 8),
              Text(
                'Copia de Seguridad Válida',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: BackupRestoreDialog._kTeal),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Creada el $dateStr · App: ${m.app} v${m.version}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildDetailRow('👤 Perfiles clínicos:', '${m.profilesCount} (${m.activeProfileName})'),
          _buildDetailRow('🗂️ Tableros y cuadrículas:', '${m.boardsCount} tableros'),
          _buildDetailRow('💬 Frases rápidas:', '${m.customPhrasesCount} frases personalizadas'),
          _buildDetailRow('📜 Historial clínico:', '${m.historyCount} registros'),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _overwriteExisting,
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: BackupRestoreDialog._kTeal,
            title: const Text(
              'Sobrescribir datos locales existentes',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Si se desmarca, se combinarán los datos sin borrar los actuales.',
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
            onChanged: (val) {
              setState(() => _overwriteExisting = val ?? true);
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _pendingBackupData = null),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text('Restaurar Todo'),
                style: FilledButton.styleFrom(
                  backgroundColor: BackupRestoreDialog._kTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () => _executeRestore(data),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _exportFullBackup() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generando copia de seguridad .matata...';
    });

    try {
      final now = DateTime.now();
      final dateTag = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'MatataTalk_Backup_$dateTag.matata';

      final bytes = await _backupService.createBackupBytes(
        notes: 'Copia clínica generada desde MatataTalk',
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: fileName,
              mimeType: 'application/zip',
            ),
          ],
          text: 'Copia de seguridad completa de MatataTalk (.matata)',
        ),
      );
    } catch (e) {
      _showSnackbar('Error al generar respaldo: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndInspectBackupFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['matata', 'zip'],
      );

      if (file == null) return;

      setState(() {
        _isLoading = true;
        _statusMessage = 'Verificando archivo ${file.name}...';
      });

      final bytes = await file.readAsBytes();
      final data = BackupRestoreService.parseBackupDataFromBytes(bytes);

      setState(() {
        _pendingBackupData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackbar('Error al leer el archivo de respaldo: $e', isError: true);
      }
    }
  }

  Future<void> _executeRestore(BackupData data) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Restaurando perfiles, tableros y frases...';
    });

    try {
      final result = await _backupService.restoreBackup(
        data,
        overwrite: _overwriteExisting,
      );

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Error desconocido');
      }

      if (mounted) {
        // Notificar en caliente a todos los BLoCs activos de la aplicación
        context.read<ProfileBloc>().add(const LoadProfiles());
        context.read<TouchSettingsBloc>().add(UpdateTouchSettings(data.touchSettings));
        context.read<ScanningBloc>().add(UpdateScanningSettings(data.scanningSettings));
        context.read<HeadPointerBloc>().add(UpdateHeadPointerSettings(data.headPointerSettings));
        context.read<PhrasesBloc>().add(const LoadPhrases());

        final rootBoard = data.profiles.isNotEmpty
            ? data.profiles.firstWhere(
                (p) => p.id == data.activeProfileId,
                orElse: () => data.profiles.first,
              ).rootBoardId
            : 'home_board';

        context.read<GridBloc>().add(LoadBoard(rootBoard));

        Navigator.of(context).pop();
        _showGlobalSnackbar(
          '¡Restauración exitosa! Se recuperaron ${result.profilesRestored} perfiles y ${result.boardsRestored} tableros.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackbar('Error durante la restauración: $e', isError: true);
      }
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : BackupRestoreDialog._kTeal,
      ),
    );
  }

  void _showGlobalSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
