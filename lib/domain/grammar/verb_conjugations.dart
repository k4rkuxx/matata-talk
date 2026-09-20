import 'package:equatable/equatable.dart';

class VerbConjugations extends Equatable {
  final String infinitive;
  final List<String> present;     // [yo, tú, él/ella, nosotros, ellos]
  final List<String> past;        // Pretérito perfecto simple
  final List<String> future;      // Futuro simple
  final String gerund;            // comiendo / jugando
  final String participle;        // comido / jugado
  final String imperative;        // ¡come! / ¡juega!

  const VerbConjugations({
    required this.infinitive,
    required this.present,
    required this.past,
    required this.future,
    required this.gerund,
    required this.participle,
    required this.imperative,
  });

  // Métodos seguros contra RangeError
  String getPresent(int index) =>
      (index >= 0 && index < present.length) ? present[index] : infinitive;

  String getPast(int index) =>
      (index >= 0 && index < past.length) ? past[index] : infinitive;

  String getFuture(int index) =>
      (index >= 0 && index < future.length) ? future[index] : infinitive;

  @override
  List<Object?> get props => [
        infinitive,
        present,
        past,
        future,
        gerund,
        participle,
        imperative,
      ];
}
