
import 'package:animated_exam_page/pages/ExamPage/components/AnswerState.dart';

typedef Listener = void Function(AnswerState answerState);

class StackController {
  List<Listener> _listeners = [];

  void addListener(Listener listener) {
    _listeners.add((listener));
  }

  void update(AnswerState answerState) {
    _listeners.forEach((listener) {
      listener(answerState);
    });
  }
}
