import 'dart:async';
import 'dart:ui';

import 'package:animated_exam_page/models/Question.dart';
import 'package:animated_exam_page/models/StackController.dart';
import 'package:animated_exam_page/pages/ExamPage/components/AnswerState.dart';
import 'package:animated_exam_page/pages/ExamPage/components/CongCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../components/AnimatedStack.dart';
import 'components/AnswerHistoryWithLessThan9Box.dart';
import 'components/AnswerHistoryWithMoreThan9Box.dart';
import 'components/QuestionCard.dart';
import 'components/ReportBox.dart';

class ExamPageBody extends StatefulWidget {
  ExamPageBody({Key? key, required this.questions}) : super(key: key);

  final List<Question> questions;

  @override
  State<ExamPageBody> createState() => _ExamPageBodyState();
}

class _ExamPageBodyState extends State<ExamPageBody>
    with SingleTickerProviderStateMixin {
  final StackController _stackController = StackController();

  Duration _timerDuration = const Duration();
  final Duration _animationDuration = const Duration(seconds: 1);
  Timer? _timer;
  late double _progressBarIncrementSize;
  double _progressPercent = 0;
  late AnimationController _animationController;
  late CongCard congCard;
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  int _trueAnswers = 0;

  @override
  void initState() {
    _progressBarIncrementSize = 1 / widget.questions.length;
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    _animationController.addListener(() {
      setState(() {});
    });
    congCard = CongCard(animationController: _animationController);
    super.initState();
    _startTimer();

    _stackController.addListener(_calculateTrueAnswers);
  }

  _calculateTrueAnswers(dynamic state) {
    state = state as AnswerState;
    if (state == AnswerState.trueAnswer) {
      _trueAnswers++;
    }
  }

  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _addSecond();
    });
  }

  _addSecond() {
    setState(() {
      final seconds = _timerDuration.inSeconds + 1;
      _timerDuration = Duration(seconds: seconds);
    });
  }

  _incrementProgressBarValue() {
    setState(() {
      _progressPercent += _progressBarIncrementSize;
    });
  }

  List<Widget> _buildQuestionCards() {
    var li = <Widget>[];
    for (int i = 0; i < widget.questions.length; i++) {
      Question question = widget.questions[i];
      Key key = GlobalKey(debugLabel: 'QUESTION_CARD$i');
      Widget card = QuestionCard(
        key: key,
        stackController: _stackController,
        question: question.questionText,
        choices: question.choices,
        point: question.point,
        numberOfQuestion: i + 1,
        totalQuestion: widget.questions.length,
        correctAnswerIndex: question.correctAnswerIndex,
        onFinishBtnClicked: () {
          _timer!.cancel();
          _incrementProgressBarValue();
          _animationController.forward();
        },
        onNextBtnClicked: () {
          _incrementProgressBarValue();
        },
        onSkipBtnClicked: () {
          _stackController.update(AnswerState.notAnswered);
          _incrementProgressBarValue();
        },
        onReportClicked: () {
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            barrierColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => ReportBox(
              draggableScrollableController: draggableScrollableController,
              definitions: 'Choose a reason to report from the list below',
              title: 'What\'s wrong? ',
            ),
          );
        },
      );
      li.add(card);
    }
    return li;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      fit: StackFit.expand,
      children: [
        _buildCongText(),
        _buildCongDefinitionsText(),
        _buildCongCard(),
        _buildProgressBar(),
        _buildBackIcon(),
        _buildTimerBox(),
        _buildClockIcon(),
        _buildAnswerHistory(),
        _buildAnimatedStack(),
      ],
    );
  }

  _buildProgressBar() {
    return Positioned(
      top: (_animationController.value != 0)
          ? ExamPageAnimations.hideProgressBarAnimation(_animationController)
              .value
          : 0,
      child: SizedBox(
        width: 375.w,
        child: LinearPercentIndicator(
          padding: EdgeInsets.zero,
          backgroundColor: Color(0xffDFDFDF),
          progressColor: Color(0xff5B38AD),
          percent: _progressPercent,
          lineHeight: 8.h,
          barRadius: const Radius.circular(32),
          animation: true,
          animationDuration: 300,
          animateFromLastPercent: true,
        ),
      ),
    );
  }

  _buildBackIcon() => Positioned(
        top: 25.h,
        left: (_animationController.value != 0)
            ? ExamPageAnimations.hideTimerClockIconAnimation(
                    _animationController)
                .value
            : 20.w,
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: SvgPicture.asset(
            'assets/icons/back-arrow.svg',
            color: Colors.white,
            width: 25.w,
            height: 25.w,
          ),
        ),
      );

  _buildTimerBox() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minute = twoDigits(_timerDuration.inMinutes);
    String second = twoDigits(_timerDuration.inSeconds.remainder(60));
    return Positioned(
      right: (_animationController.value != 0)
          ? ExamPageAnimations.hideTimerBoxAnimation(_animationController).value
          : 50.w,
      top: 25.h,
      child: Container(
        height: 21.w,
        width: 70.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Text(
            '$minute:$second',
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  _buildClockIcon() => Positioned(
        top: 25.h,
        right: (_animationController.value != 0)
            ? ExamPageAnimations.hideTimerClockIconAnimation(
                    _animationController)
                .value
            : 20.w,
        child: SvgPicture.asset(
          'assets/icons/alarm.svg',
          width: 20.w,
          height: 20.w,
        ),
      );

  _buildAnimatedStack() {
    return Positioned(
      top: (_animationController.value >= .51)
          ? ExamPageAnimations.animatedStackMoveOutAnimation(
                  _animationController)
              .value
          : 130.h,
      child: Opacity(
        opacity: (_animationController.value != 0)
            ? ExamPageAnimations.hideStackCardAnimation(_animationController)
                .value
            : 1,
        child: AnimatedStack(
          cards: _buildQuestionCards(),
          stackController: _stackController,
          isReversed: true,
        ),
      ),
    );
  }

  _buildCongText() {
    return Positioned(
      top: 66.h,
      child: Opacity(
        opacity: (_animationController.value != 0)
            ? ExamPageAnimations.showCongElementsAnimation(_animationController)
                .value
            : 0,
        child: Text(
          _getCongTitle(),
          style: GoogleFonts.roboto(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }

  _getCongTitle() {
    if (_trueAnswers >= widget.questions.length / 2) {
      return 'Congratulations!';
    }
    return 'Try harder ):';
  }

  _buildCongDefinitionsText() {
    return Positioned(
      top: 122.h,
      child: Opacity(
        opacity: (_animationController.value != 0)
            ? ExamPageAnimations.showCongElementsAnimation(_animationController)
                .value
            : 0,
        child: Text(
          _getConDefinitionsText(),
          style: GoogleFonts.roboto(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white),
        ),
      ),
    );
  }

  _getConDefinitionsText(){
    if (_trueAnswers >= widget.questions.length / 2) {
      return 'You answered most of the questions correctly';
    }
    return 'Number of correct answers was low';
  }

  _buildCongCard() {
    return Positioned(
      top: 170.h,
      child: Opacity(
        opacity: (_animationController.value != 0)
            ? ExamPageAnimations.showCongElementsAnimation(_animationController)
                .value
            : 0,
        child: congCard,
      ),
    );
  }

  _buildAnswerHistory() {
    Widget answerHistory;
    if (widget.questions.length > 9) {
      answerHistory = AnswerHistoryWithMoreThan9Box(
          questionsCount: widget.questions.length,
          stackController: _stackController);
    } else {
      answerHistory = AnswerHistoryWithLessThan9Box(
          questionsCount: widget.questions.length,
          stackController: _stackController);
    }
    return Positioned(
      top: 75.h,
      child: Opacity(
        opacity: (_animationController.value != 0)
            ? ExamPageAnimations.hideBackAnsweredHistory(_animationController)
                .value
            : 1,
        child: answerHistory,
      ),
    );
  }
}

class ExamPageAnimations {
  static Animation<double> hideProgressBarAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 0, end: -8.h).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0,
          0.2,
        ),
      ),
    );
  }

  static Animation<double> hideTimerBoxAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 50.w, end: -120.w).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.2,
          0.3,
        ),
      ),
    );
  }

  static Animation<double> hideTimerClockIconAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 20.w, end: -40.w).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.2,
          0.3,
        ),
      ),
    );
  }

  static Animation<double> hideBackIconAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 20.w, end: -10.w).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.2,
          0.3,
        ),
      ),
    );
  }

  static Animation<double> hideBackAnsweredHistory(
      AnimationController animationController) {
    return Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.2,
          0.3,
        ),
      ),
    );
  }

  static Animation<double> hideStackCardAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.3,
          0.5,
        ),
      ),
    );
  }

  static Animation<double> showCongElementsAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.6,
          .8,
        ),
      ),
    );
  }

  static Animation<double> animatedStackMoveOutAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 0, end: 585.h * 2).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.51,
          .8,
        ),
      ),
    );
  }
}
