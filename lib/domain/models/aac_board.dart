import 'package:equatable/equatable.dart';
import 'aac_button.dart';

class AACBoard extends Equatable {
  final String id;
  final String name;
  final int rows;
  final int columns;
  final List<AACButton> buttons;

  const AACBoard({
    required this.id,
    required this.name,
    required this.rows,
    required this.columns,
    required this.buttons,
  });

  /// Recupera el botón en la posición fija para preservar la memoria motora
  AACButton? getButtonAt(int row, int col) {
    try {
      return buttons.firstWhere((b) => b.row == row && b.col == col);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [id, name, rows, columns, buttons];
}
