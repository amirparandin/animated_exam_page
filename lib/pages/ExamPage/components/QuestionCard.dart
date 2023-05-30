import 'package:animated_exam_page/models/StackController.dart';
import 'package:animated_exam_page/pages/components/bounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import 'AnswerState.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    Key? key,
    required this.numberOfQuestion,
    required this.totalQuestion,
    required this.question,
    required this.correctAnswerIndex,
    required this.point,
    required this.onNextBtnClicked,
    required this.onFinishBtnClicked,
    required this.choices,
    required this.onSkipBtnClicked,
    required this.stackController,
    required this.onReportClicked,
  }) : super(key: key);

  final int numberOfQuestion;
  final int totalQuestion;
  final String question;
  final int correctAnswerIndex;
  final List<String> choices;
  final int point;
  final void Function() onNextBtnClicked;
  final void Function() onFinishBtnClicked;
  final void Function() onSkipBtnClicked;
  final StackController stackController;
  final void Function() onReportClicked;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _mainBtnEnable = false;
  bool _skipEnable = true;
  bool _isSecondClick = false;
  Bounce? _trueAnswerBox;
  bool _questionAnswered = false;
  bool _soundEffectPlayed = false;
  List<BoxDecoration> _decorations = [];
  List<Color> _colors = [];
  final AudioPlayer _player = AudioPlayer();
  int _selectedAnswer = 0;

  final BoxDecoration _trueBoxDecoration = BoxDecoration(
    boxShadow: const [
      BoxShadow(
        color: Color(0xff4CAF50),
        blurRadius: 20,
        spreadRadius: 0.5,
      )
    ],
    color: const Color(0xff4CAF50),
    borderRadius: BorderRadius.circular(32.h),
  );

  final BoxDecoration _wrongAnswerDecoration = BoxDecoration(
    boxShadow: const [
      BoxShadow(
        color: Color(0xffD32F2F),
        blurRadius: 20,
        spreadRadius: 0.5,
      )
    ],
    color: Color(0xffD32F2F),
    borderRadius: BorderRadius.circular(32),
  );

  final BoxDecoration _sampleDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(32),
  );

  @override
  void initState() {
    for (int i = 0; i < widget.choices.length; i++) {
      _decorations.add(_sampleDecoration);
      _colors.add(Colors.black);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 350.w,
          height: 585.h,
          padding: EdgeInsets.fromLTRB(25.w, 10.h, 25.w, 4.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: const Color(0xffF5F4F6),
          ),
        ),
        _buildCounterBar(),
        SizedBox(height: 35.h),
        _buildQuestion(),
        SizedBox(height: 55.h),
        _buildAllAnswers(),
        SizedBox(
          height: 30.h,
        ),
        widget.totalQuestion == widget.numberOfQuestion
            ? _buildMainBtn(_mainBtnEnable, 'Finish', widget.onFinishBtnClicked)
            : _buildMainBtn(
                _mainBtnEnable,
                'Next',
                () {
                  widget.onNextBtnClicked();
                  widget.stackController.update(
                    (_selectedAnswer == widget.correctAnswerIndex)
                        ? AnswerState.trueAnswer
                        : AnswerState.falseAnswer,
                  );
                },
              ),
        _buildSkipBtn(_skipEnable),
      ],
    );
  }

  _playAudioEffect({required bool trueEffect}) async {
    await _player.setAsset(trueEffect
        ? 'assets/audios/gold-prize.mp3'
        : 'assets/audios/multimedia-error.mp3');
    await _player.play();
  }

  _buildChoiceBox(String choice, {required int choiceIndex}) {
    bool isAnswer = choiceIndex == widget.correctAnswerIndex;
    BoxDecoration boxDecoration = _decorations[choiceIndex];
    Color textColor = _colors[choiceIndex];
    double width = MediaQuery.of(context).size.width;
    return Bounce(
      duration: const Duration(milliseconds: 100),
      onPressed: () {
        setState(() {
          if (_questionAnswered) {
            return;
          }
          if (!_soundEffectPlayed) {
            _playAudioEffect(trueEffect: isAnswer);
            _soundEffectPlayed = true;
          }
          if (isAnswer) {
            _decorations[choiceIndex] = _trueBoxDecoration;
          } else {
            _decorations[choiceIndex] = _wrongAnswerDecoration;

            _trueAnswerBox!.onPressed();
          }

          _selectedAnswer = choiceIndex;
          _colors[choiceIndex] = Colors.white;
          _questionAnswered = true;
          _mainBtnEnable = true;
          _skipEnable = false;
        });
      },
      child: Container(
        width: 0.37 * width,
        height: 0.37 * width,
        decoration: boxDecoration,
        child: Center(
          child: Text(
            choice,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: 18.sp,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildCounterBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(21.w, 0, 21.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Question ${widget.numberOfQuestion} of ${widget.totalQuestion}',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: Color(0xff616161),
              ),
            ),
          ),
          Row(
            children: [
              _buildPlaySoundBtn(),
              // SizedBox(width: 15.w),
              _buildReportBtn(),
            ],
          ),
        ],
      ),
    );
  }

  _buildPlaySoundBtn() {
    return IconButton(
      onPressed: () {},
      icon: SvgPicture.asset(
        'assets/icons/volume.svg',
        color: const Color(0xff5B38AD),
        width: 20.w,
        height: 20.w,
      ),
    );
  }

  _buildReportBtn() {
    return IconButton(
      onPressed: widget.onReportClicked,
      icon: SvgPicture.asset(
        'assets/icons/flag.svg',
        color: const Color(0xff5B38AD),
        width: 20.w,
        height: 20.w,
      ),
    );
  }

  _buildQuestion() {
    return Align(
      alignment: Alignment(0, -.80),
      child: SizedBox(
        width: 263.w,
        child: Text(
          widget.question,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            textStyle: TextStyle(fontSize: 17.sp),
          ),
        ),
      ),
    );
  }

  _buildAllAnswers() {
    List<Widget> columnChildren = [];
    List<Widget> rowChildren = [];

    for (int i = 0; i < widget.choices.length; i++) {
      Bounce choice;
      if (i == widget.correctAnswerIndex) {
        choice = _buildChoiceBox(widget.choices[i], choiceIndex: i);
        _trueAnswerBox = choice;
      } else {
        choice = _buildChoiceBox(widget.choices[i], choiceIndex: i);
      }

      rowChildren.add(choice);
      if (rowChildren.length == 2) {
        columnChildren.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowChildren,
          ),
        );
        rowChildren = [];
      }
    }
    if (rowChildren.length == 1) {
      columnChildren.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rowChildren,
        ),
      );
    }

    double width = MediaQuery.of(context).size.width;
    return Align(
      alignment: const Alignment(0, 0),
      child: SizedBox(
        height: width * .77,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: columnChildren,
        ),
      ),
    );
  }

  _buildSkipBtn(bool enable) {
    return Align(
      alignment: Alignment(-.80, .9),
      child: ElevatedButton(
        onPressed: enable
            ? () {
                if (_isSecondClick) {
                  return;
                }
                if (widget.numberOfQuestion == widget.totalQuestion) {
                  widget.onFinishBtnClicked();
                } else {
                  widget.onSkipBtnClicked();
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          primary: const Color(0xff5B38AD),
          onPrimary: Colors.white,
          fixedSize: Size(58.w, 58.w),
          elevation: 20,
          shadowColor: const Color(0xff5B38AD).withOpacity(0.5),
        ),
        child: SvgPicture.asset(
          'assets/icons/redo.svg',
          width: 25.w,
          height: 25.w,
        ),
      ),
    );
  }

  Widget _buildMainBtn(bool enable, String title, void Function() onClicked) =>
      Align(
        alignment: Alignment(.65, .9),
        child: ElevatedButton(
          onPressed: enable
              ? () {
                  if (_isSecondClick) {
                    return;
                  }
                  onClicked();
                }
              : null,
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff5B38AD),
            onPrimary: Colors.white,
            fixedSize: Size(229.w, 58.w),
            elevation: 20,
            shadowColor: const Color(0xff5B38AD).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Text(
            title,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
}
