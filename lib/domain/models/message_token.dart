import 'package:equatable/equatable.dart';
import 'aac_button.dart';

class MessageToken extends Equatable {
  final String id;
  final AACButton button;

  const MessageToken({
    required this.id,
    required this.button,
  });

  @override
  List<Object?> get props => [id, button];
}
