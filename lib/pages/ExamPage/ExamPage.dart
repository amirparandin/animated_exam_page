import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../models/Question.dart';
import 'ExamPageBody.dart';

class ExamPage extends StatelessWidget {
  ExamPage({Key? key}) : super(key: key);
  List<Question> questions = [
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you eat something?',
        point: 2,
        correctAnswerIndex: 2,
        choices: ['no', 'I am thirsty', 'I\'m heavy', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),

    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you eat something?',
        point: 2,
        correctAnswerIndex: 2,
        choices: ['no', 'I am thirsty', 'I\'m heavy', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),

    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
    Question(
        questionText: 'can you eat something?',
        point: 2,
        correctAnswerIndex: 2,
        choices: ['no', 'I am thirsty', 'I\'m heavy', 'ha?']),
    Question(
        questionText: 'can you do something?',
        point: 4,
        correctAnswerIndex: 1,
        choices: ['no', 'maybe', 'i don\'t know', 'ha?']),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Lottie.asset(
            'assets/lotties/background_animation.json',
            height: double.infinity,
            fit: BoxFit.fill,
          ),
          ExamPageBody(questions: questions),
        ],
      ),
    );
  }
}
