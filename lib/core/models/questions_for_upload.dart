import 'dart:io';

class Choice {
  final String text;
  final bool isCorrect;

  Choice({ required this.text, required this.isCorrect});
}

class Question {
  final String text;
  final File? image;
  final List<Choice> choices;

  Question({
    required this.text,
    this.image,
    required this.choices,
  });
}