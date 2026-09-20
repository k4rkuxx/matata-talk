import 'package:flutter/material.dart';
import '../../../../domain/models/aac_board.dart';
import '../../../../domain/models/aac_button.dart';
import 'aac_button_widget.dart';

class MotorGridView extends StatelessWidget {
  final AACBoard board;
  final Function(AACButton) onButtonTap;
  final Function(AACButton)? onButtonLongPress;

  const MotorGridView({
    super.key,
    required this.board,
    required this.onButtonTap,
    this.onButtonLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: board.columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: (constraints.maxWidth / board.columns) /
                (constraints.maxHeight / board.rows),
          ),
          itemCount: board.rows * board.columns,
          itemBuilder: (context, index) {
            final row = index ~/ board.columns;
            final col = index % board.columns;
            final button = board.getButtonAt(row, col);

            if (button == null) {
              return const SizedBox.shrink();
            }

            return AACButtonWidget(
              button: button,
              onTap: () => onButtonTap(button),
              onLongPress: onButtonLongPress != null
                  ? () => onButtonLongPress!(button)
                  : null,
            );
          },
        );
      },
    );
  }
}
