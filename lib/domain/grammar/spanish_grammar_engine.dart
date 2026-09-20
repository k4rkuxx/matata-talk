import 'grammar_engine.dart';
import 'verb_conjugations.dart';

class SpanishGrammarEngine implements GrammarEngine {
  // Mapa de lematización: Formas comunes en CAA -> Infinitivo
  static const Map<String, String> _lemmas = {
    'quiero': 'querer',
    'quieres': 'querer',
    'quiere': 'querer',
    'queremos': 'querer',
    'quieren': 'querer',
    'voy': 'ir',
    'vas': 'ir',
    'va': 'ir',
    'vamos': 'ir',
    'van': 'ir',
    'fui': 'ir',
    'fue': 'ir',
    'tengo': 'tener',
    'tienes': 'tener',
    'tiene': 'tener',
    'tenemos': 'tener',
    'puedo': 'poder',
    'puedes': 'poder',
    'puede': 'poder',
    'podemos': 'poder',
    'hago': 'hacer',
    'haces': 'hacer',
    'hace': 'hacer',
    'hacemos': 'hacer',
    'veo': 'ver',
    'ves': 'ver',
    've': 'ver',
    'vemos': 'ver',
    'juego': 'jugar',
    'juegas': 'jugar',
    'juega': 'jugar',
    'jugamos': 'jugar',
    'como': 'comer',
    'comes': 'comer',
    'come': 'comer',
    'comemos': 'comer',
    'bebo': 'beber',
    'bebes': 'beber',
    'bebe': 'beber',
    'bebemos': 'beber',
    'estoy': 'estar',
    'estás': 'estar',
    'está': 'estar',
    'estamos': 'estar',
    'soy': 'ser',
    'eres': 'ser',
    'es': 'ser',
    'somos': 'ser',
  };

  // Diccionario de verbos irregulares clave
  static final Map<String, VerbConjugations> _irregularVerbs = {
    'querer': const VerbConjugations(
      infinitive: 'querer',
      present: ['quiero', 'quieres', 'quiere', 'queremos', 'quieren'],
      past: ['quise', 'quisiste', 'quiso', 'quisimos', 'quisieron'],
      future: ['querré', 'querrás', 'querrá', 'querremos', 'querrán'],
      gerund: 'queriendo',
      participle: 'querido',
      imperative: 'quiere',
    ),
    'ir': const VerbConjugations(
      infinitive: 'ir',
      present: ['voy', 'vas', 'va', 'vamos', 'van'],
      past: ['fui', 'fuiste', 'fue', 'fuimos', 'fueron'],
      future: ['iré', 'irás', 'irá', 'iremos', 'irán'],
      gerund: 'yendo',
      participle: 'ido',
      imperative: 've',
    ),
    'jugar': const VerbConjugations(
      infinitive: 'jugar',
      present: ['juego', 'juegas', 'juega', 'jugamos', 'juegan'],
      past: ['jugué', 'jugaste', 'jugó', 'jugamos', 'jugaron'],
      future: ['jugaré', 'jugarás', 'jugará', 'jugaremos', 'jugarán'],
      gerund: 'jugando',
      participle: 'jugado',
      imperative: 'juega',
    ),
    'tener': const VerbConjugations(
      infinitive: 'tener',
      present: ['tengo', 'tienes', 'tiene', 'tenemos', 'tienen'],
      past: ['tuve', 'tuviste', 'tuvo', 'tuvimos', 'tuvieron'],
      future: ['tendré', 'tendrás', 'tendrá', 'tendremos', 'tendrán'],
      gerund: 'teniendo',
      participle: 'tenido',
      imperative: 'ten',
    ),
    'hacer': const VerbConjugations(
      infinitive: 'hacer',
      present: ['hago', 'haces', 'hace', 'hacemos', 'hacen'],
      past: ['hice', 'hiciste', 'hizo', 'hicimos', 'hicieron'],
      future: ['haré', 'harás', 'hará', 'haremos', 'harán'],
      gerund: 'haciendo',
      participle: 'hecho',
      imperative: 'haz',
    ),
    'ver': const VerbConjugations(
      infinitive: 'ver',
      present: ['veo', 'ves', 've', 'vemos', 'ven'],
      past: ['vi', 'viste', 'vio', 'vimos', 'vieron'],
      future: ['veré', 'verás', 'verá', 'veremos', 'verán'],
      gerund: 'viendo',
      participle: 'visto',
      imperative: 'mira',
    ),
    'poder': const VerbConjugations(
      infinitive: 'poder',
      present: ['puedo', 'puedes', 'puede', 'podemos', 'pueden'],
      past: ['pude', 'pudiste', 'pudo', 'pudimos', 'pudieron'],
      future: ['podré', 'podrás', 'podrá', 'podremos', 'podrán'],
      gerund: 'pudiendo',
      participle: 'podido',
      imperative: 'puede',
    ),
    'ser': const VerbConjugations(
      infinitive: 'ser',
      present: ['soy', 'eres', 'es', 'somos', 'son'],
      past: ['fui', 'fuiste', 'fue', 'fuimos', 'fueron'],
      future: ['seré', 'serás', 'será', 'seremos', 'serán'],
      gerund: 'siendo',
      participle: 'sido',
      imperative: 'sé',
    ),
    'estar': const VerbConjugations(
      infinitive: 'estar',
      present: ['estoy', 'estás', 'está', 'estamos', 'están'],
      past: ['estuve', 'estuviste', 'estuvo', 'estuvimos', 'estuvieron'],
      future: ['estaré', 'estarás', 'estará', 'estaremos', 'estarán'],
      gerund: 'estando',
      participle: 'estado',
      imperative: 'está',
    ),
  };

  @override
  VerbConjugations conjugateVerb(String rawWord) {
    var word = rawWord.toLowerCase().trim();

    // 1. Convertir forma conjugada en infinitivo si está en el lematizador
    if (_lemmas.containsKey(word)) {
      word = _lemmas[word]!;
    }

    // 2. Verificar si es irregular
    if (_irregularVerbs.containsKey(word)) {
      return _irregularVerbs[word]!;
    }

    // 3. Conjugador de verbos regulares (-ar, -er, -ir)
    if (word.endsWith('ar') && word.length > 2) {
      final root = word.substring(0, word.length - 2);
      return VerbConjugations(
        infinitive: word,
        present: ['${root}o', '${root}as', '${root}a', '${root}amos', '${root}an'],
        past: ['${root}é', '${root}aste', '${root}ó', '${root}amos', '${root}aron'],
        future: ['${word}é', '${word}ás', '${word}á', '${word}emos', '${word}án'],
        gerund: '${root}ando',
        participle: '${root}ado',
        imperative: '${root}a',
      );
    } else if (word.endsWith('er') && word.length > 2) {
      final root = word.substring(0, word.length - 2);
      return VerbConjugations(
        infinitive: word,
        present: ['${root}o', '${root}es', '${root}e', '${root}emos', '${root}en'],
        past: ['${root}í', '${root}iste', '${root}ió', '${root}imos', '${root}ieron'],
        future: ['${word}é', '${word}ás', '${word}á', '${word}emos', '${word}án'],
        gerund: '${root}iendo',
        participle: '${root}ido',
        imperative: '${root}e',
      );
    } else if (word.endsWith('ir') && word.length > 2) {
      final root = word.substring(0, word.length - 2);
      return VerbConjugations(
        infinitive: word,
        present: ['${root}o', '${root}es', '${root}e', '${root}imos', '${root}en'],
        past: ['${root}í', '${root}iste', '${root}ió', '${root}imos', '${root}ieron'],
        future: ['${word}é', '${word}ás', '${word}á', '${word}emos', '${word}án'],
        gerund: '${root}iendo',
        participle: '${root}ido',
        imperative: '${root}e',
      );
    }

    // Fallback seguro
    return VerbConjugations(
      infinitive: word,
      present: [word, word, word, word, word],
      past: [word, word, word, word, word],
      future: [word, word, word, word, word],
      gerund: word,
      participle: word,
      imperative: word,
    );
  }

  @override
  String pluralizeNoun(String noun) {
    final word = noun.trim();
    if (word.isEmpty) return word;
    final lower = word.toLowerCase();

    if (lower.endsWith('z')) {
      return '${word.substring(0, word.length - 1)}ces';
    }
    if (RegExp(r'[aeiouáéó]$', caseSensitive: false).hasMatch(word)) {
      return '${word}s';
    }
    return '${word}es';
  }

  @override
  String feminineForm(String word) {
    final w = word.trim();
    if (w.isEmpty) return w;
    if (w.endsWith('o') || w.endsWith('O')) {
      return '${w.substring(0, w.length - 1)}a';
    }
    return w;
  }
}
