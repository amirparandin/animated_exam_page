class Question {
  String questionText;
  int point;
  int correctAnswerIndex;
  List<String> choices;

  Question({
    required this.questionText,
    required this.point,
    required this.correctAnswerIndex,
    required this.choices,
  });
}
