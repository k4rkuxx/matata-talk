import 'package:flutter/material.dart';
import '../../domain/models/part_of_speech.dart';

class FitzgeraldColors {
  // Paleta accesible con alto contraste WCAG AAA
  static const Color pronoun = Color(0xFFFFF59D);     // Amarillo (Pronombres/Personas)
  static const Color verb = Color(0xFFA5D6A7);        // Verde (Verbos/Acciones)
  static const Color noun = Color(0xFFFFCC80);        // Naranja (Sustantivos)
  static const Color adjective = Color(0xFF90CAF9);   // Azul (Adjetivos/Descriptores)
  static const Color social = Color(0xFFCE93D8);      // Rosa/Morado (Social/Fórmulas)
  static const Color preposition = Color(0xFFE0E0E0); // Gris (Conectores/Preposiciones)
  static const Color important = Color(0xFFEF9A9A);   // Rojo (No, Parar, Ayuda)
  static const Color misc = Color(0xFFF5F5F5);        // Neutro

  static Color getColor(PartOfSpeech pos) {
    switch (pos) {
      case PartOfSpeech.pronoun:
        return pronoun;
      case PartOfSpeech.verb:
        return verb;
      case PartOfSpeech.noun:
        return noun;
      case PartOfSpeech.adjective:
        return adjective;
      case PartOfSpeech.social:
        return social;
      case PartOfSpeech.preposition:
        return preposition;
      case PartOfSpeech.important:
        return important;
      case PartOfSpeech.misc:
        return misc;
    }
  }

  static Color getBorderColor(PartOfSpeech pos) {
    return getColor(pos).withValues(alpha: 0.8);
  }
}
