import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/user_profile.dart';
import '../../grid/bloc/grid_bloc.dart';
import '../../head_pointer/bloc/head_pointer_bloc.dart';
import '../../scanning/bloc/scanning_bloc.dart';
import '../../settings/bloc/touch_settings_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfileManagementDialog extends StatelessWidget {
  const ProfileManagementDialog({super.key});

  static const Color _kThemePurple = Color(0xFF7B1FA2);

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
            // ── Cabecera Unificada (Púrpura Terapéutico) ────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: _kThemePurple,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perfiles de Usuario',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Soporte multi-usuario para terapeutas y escuelas',
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

            // ── Cuerpo de Lista de Perfiles ──────────────────────────────
            Flexible(
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message!),
                        backgroundColor: const Color(0xFF2E7D32),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final profiles = state.profiles;
                  final active = state.activeProfile;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cada perfil almacena de forma independiente los filtros motores, conmutadores y tableros personalizados de cada alumno o paciente.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        ...profiles.map((p) {
                          final isActive = p.id == active?.id;
                          return _buildProfileCard(context, p, isActive);
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Divisor ───────────────────────────────────────────────────
            const Divider(height: 1),

            // ── Botones de Acción Inferiores ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                    label: const Text('Nuevo Perfil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kThemePurple,
                      side: const BorderSide(color: _kThemePurple),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showCreateProfileDialog(context),
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

  Widget _buildProfileCard(BuildContext context, UserProfile profile, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF3E5F5) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? _kThemePurple : const Color(0xFFE0E0E0),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: _kThemePurple.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? _kThemePurple.withValues(alpha: 0.5) : Colors.black12,
            ),
          ),
          child: Center(
            child: Text(
              profile.avatarEmoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                profile.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isActive ? _kThemePurple : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _kThemePurple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACTIVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile.notes.isNotEmpty)
              Text(
                profile.notes,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 2),
            Text(
              'Toque: ${profile.touchSettings.holdDurationMs}ms · Barrido: ${profile.scanningSettings.enabled ? "Sí" : "No"} · Cabeza: ${profile.headPointerSettings.enabled ? "Sí" : "No"}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isActive)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kThemePurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _activateProfile(context, profile),
                child: const Text('Activar'),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
              tooltip: 'Eliminar perfil',
              onPressed: () => _confirmDeleteProfile(context, profile),
            ),
          ],
        ),
        onTap: isActive ? null : () => _activateProfile(context, profile),
      ),
    );
  }

  void _activateProfile(BuildContext context, UserProfile profile) {
    // 1. Notificar a ProfileBloc
    context.read<ProfileBloc>().add(SwitchProfile(profile.id));

    // 2. Sincronizar los BLoCs de accesibilidad y navegación al perfil seleccionado
    context.read<TouchSettingsBloc>().add(UpdateTouchSettings(profile.touchSettings));
    context.read<ScanningBloc>().add(UpdateScanningSettings(profile.scanningSettings));
    context.read<HeadPointerBloc>().add(UpdateHeadPointerSettings(profile.headPointerSettings));
    context.read<GridBloc>().add(LoadBoard(profile.rootBoardId));
  }

  void _confirmDeleteProfile(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('¿Eliminar perfil "${profile.name}"?'),
        content: const Text(
          'Se eliminarán sus configuraciones asociadas. Esta acción no se puede deshacer.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              context.read<ProfileBloc>().add(DeleteProfileEvent(profile.id));
              Navigator.of(dContext).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCreateProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedEmoji = '🧒';

    final emojis = ['🧒', '👧', '🦁', '⭐', '🚀', '🎨', '🌈', '🧩', '🌻', '🧸', '💡', '🎵'];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: _kThemePurple),
              SizedBox(width: 8),
              Text('Nuevo Perfil Clínico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nombre del usuario / alumno',
                    hintText: 'Ej. Sofía, Lucas, Aula 3...',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: 'Notas clínicas (opcional)',
                    hintText: 'Ej. Terapeuta María · Sesiones martes',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Selecciona un Avatar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                          color: isSelected ? const Color(0xFFE1BEE7) : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? _kThemePurple : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
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
              style: FilledButton.styleFrom(backgroundColor: _kThemePurple),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  context.read<ProfileBloc>().add(CreateProfile(
                        name: nameCtrl.text.trim(),
                        avatarEmoji: selectedEmoji,
                        notes: notesCtrl.text.trim(),
                        rootBoardId: 'home_board',
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
}
