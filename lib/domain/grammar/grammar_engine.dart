import 'verb_conjugations.dart';

abstract class GrammarEngine {
  VerbConjugations conjugateVerb(String verb);
  String pluralizeNoun(String noun);
  String feminineForm(String word);
}
