import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/scanning_settings.dart';
import '../bloc/scanning_bloc.dart';

class ScanningSettingsDialog extends StatefulWidget {
  const ScanningSettingsDialog({super.key});

  @override
  State<ScanningSettingsDialog> createState() => _ScanningSettingsDialogState();
}

class _ScanningSettingsDialogState extends State<ScanningSettingsDialog> {
  late ScanningSettings _draft;

  static const Color _kAccent = Color(0xFFFF8F00);

  @override
  void initState() {
    super.initState();
    _draft = context.read<ScanningBloc>().state.settings;
  }

  void _save() {
    context.read<ScanningBloc>().add(UpdateScanningSettings(_draft));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: screenHeight * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Cabecera Unificada (Ámbar) ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: _kAccent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings_input_component, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barrido por Conmutadores',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Control por 1 o 2 conmutadores o pantalla',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.82,
                    child: Switch(
                      value: _draft.enabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.white.withValues(alpha: 0.4),
                      onChanged: (v) =>
                          setState(() => _draft = _draft.copyWith(enabled: v)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Cuerpo scrollable ──────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Modo de Activación'),
                    _modeChip(
                      ScanningMode.autoScan,
                      'Automático (1 conmutador)',
                      Icons.timer_outlined,
                      'Cursor avanza solo · Pulsación = seleccionar',
                    ),
                    _modeChip(
                      ScanningMode.stepScan,
                      'Paso a paso (2 conmutadores)',
                      Icons.swap_horiz,
                      'Switch 1 avanza · Switch 2 selecciona',
                    ),
                    _modeChip(
                      ScanningMode.inverseScan,
                      'Inverso',
                      Icons.swap_vert,
                      'Mantener para avanzar · Soltar para seleccionar',
                    ),
                    const SizedBox(height: 14),

                    _sectionLabel('Patrón de Barrido'),
                    Row(
                      children: [
                        Expanded(
                          child: _patternCard(
                            ScanningPattern.rowColumn,
                            'Fila → Columna',
                            Icons.table_rows_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _patternCard(
                            ScanningPattern.linear,
                            'Lineal',
                            Icons.view_stream_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _sectionLabel(
                      'Velocidad: ${_draft.scanSpeedSeconds.toStringAsFixed(1)}s por paso',
                    ),
                    Slider(
                      value: _draft.scanSpeedSeconds,
                      min: 0.5,
                      max: 5.0,
                      divisions: 18,
                      activeColor: _kAccent,
                      label: '${_draft.scanSpeedSeconds.toStringAsFixed(1)}s',
                      onChanged: _draft.enabled
                          ? (v) => setState(
                              () => _draft = _draft.copyWith(scanSpeedSeconds: v))
                          : null,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0.5s (rápido)',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('5.0s (lento)',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _sectionLabel('Repeticiones antes de pausar: ${_draft.maxLoops}x'),
                    Slider(
                      value: _draft.maxLoops.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: _kAccent,
                      label: '${_draft.maxLoops}x',
                      onChanged: _draft.enabled
                          ? (v) => setState(
                              () => _draft = _draft.copyWith(maxLoops: v.round()))
                          : null,
                    ),
                    const SizedBox(height: 14),

                    _sectionLabel('Opciones de Accesibilidad'),
                    _toggleTile(
                      icon: Icons.volume_up_outlined,
                      title: 'Cue auditivo',
                      subtitle: 'Lee en voz baja el pictograma al posarse',
                      value: _draft.enableAuditoryCue,
                      onChanged: (v) => setState(
                          () => _draft = _draft.copyWith(enableAuditoryCue: v)),
                    ),
                    _toggleTile(
                      icon: Icons.campaign_outlined,
                      title: 'Beep en cada paso',
                      subtitle: 'Sonido suave en cada salto del cursor',
                      value: _draft.enableAcousticBeep,
                      onChanged: (v) => setState(
                          () => _draft = _draft.copyWith(enableAcousticBeep: v)),
                    ),
                    _toggleTile(
                      icon: Icons.touch_app_outlined,
                      title: 'Pantalla como conmutador',
                      subtitle: 'Tocar en cualquier lugar = Switch 1',
                      value: _draft.screenAsSwitch,
                      onChanged: (v) => setState(
                          () => _draft = _draft.copyWith(screenAsSwitch: v)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Divisor ───────────────────────────────────────────────────
            const Divider(height: 1),

            // ── Botones de acción (siempre visibles) ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('Restablecer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          context
                              .read<ScanningBloc>()
                              .add(const ResetScanningSettings());
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _kAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: _save,
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      );

  Widget _modeChip(
      ScanningMode mode, String label, IconData icon, String hint) {
    final selected = _draft.mode == mode;
    return GestureDetector(
      onTap: _draft.enabled
          ? () => setState(() => _draft = _draft.copyWith(mode: mode))
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kAccent.withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _kAccent : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? _kAccent : Colors.grey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: selected ? _kAccent : Colors.black87,
                    ),
                  ),
                  Text(hint,
                      style:
                          const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: _kAccent, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _patternCard(ScanningPattern pattern, String label, IconData icon) {
    final selected = _draft.pattern == pattern;
    return GestureDetector(
      onTap: _draft.enabled
          ? () => setState(() => _draft = _draft.copyWith(pattern: pattern))
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? _kAccent.withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _kAccent : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? _kAccent : Colors.grey, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: selected ? _kAccent : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      secondary: Icon(icon, color: _kAccent, size: 20),
      title:
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10)),
      value: value,
      activeThumbColor: _kAccent,
      onChanged: _draft.enabled ? onChanged : null,
    );
  }
}
