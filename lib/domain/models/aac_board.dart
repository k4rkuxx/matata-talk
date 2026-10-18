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


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rows': rows,
      'columns': columns,
      'buttons': buttons.map((b) => b.toJson()).toList(),
    };
  }

  factory AACBoard.fromJson(Map<String, dynamic> json) {
    return AACBoard(
      id: json['id'] as String? ?? 'board_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Tablero',
      rows: json['rows'] as int? ?? 3,
      columns: json['columns'] as int? ?? 3,
      buttons: (json['buttons'] as List<dynamic>?)
              ?.map((b) => AACButton.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, name, rows, columns, buttons];
}
