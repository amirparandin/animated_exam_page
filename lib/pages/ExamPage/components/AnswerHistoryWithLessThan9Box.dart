import 'dart:async';
import 'dart:developer';

import 'package:animated_exam_page/models/StackController.dart';
import 'package:animated_exam_page/pages/ExamPage/components/AnswerState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AnswerHistoryWithLessThan9Box extends StatefulWidget {
  const AnswerHistoryWithLessThan9Box(
      {Key? key, required this.questionsCount, required this.stackController})
      : super(key: key);

  final int questionsCount;
  final StackController stackController;

  @override
  State<AnswerHistoryWithLessThan9Box> createState() =>
      _AnswerHistoryWithLessThan9BoxState();
}

class _AnswerHistoryWithLessThan9BoxState
    extends State<AnswerHistoryWithLessThan9Box> {
  late double _totalBoxesSpace;
  int _currentQuestionIndex = 0;
  late int _bulletPlaceIndex;
  final Duration _duration = const Duration(milliseconds: 500);
  final Curve _curve = Curves.easeIn;
  late List<double> _boxesDistancesFromLeft;
  late List<double> _boxesDistancesFromTop;
  late List<AnswerState> _states;

  @override
  void initState() {
    super.initState();

    // calculate total boxes space
    _totalBoxesSpace = (20.w + 10.w) * widget.questionsCount - 10.w;

    _boxesDistancesFromLeft = [];
    _boxesDistancesFromTop = [];
    _states = [];

    // config bullet values
    _bulletPlaceIndex = 0;

    for (var i = 0; i < widget.questionsCount; i++) {
      // initial state
      _states.add(AnswerState.notAnswered);

      _boxesDistancesFromLeft.add(_calculateFromLeftPosition(i));
      _boxesDistancesFromTop.add(6);

      // initial values for first box:
      if (i == 0) {
        _boxesDistancesFromTop[i] = 0;
      }
    }

    widget.stackController.addListener(_doNext);
  }

  void _doNext(dynamic state) {
    state = state as AnswerState;
    _states[_currentQuestionIndex] = state;

    _doNextOperationWithoutScroll();
    _currentQuestionIndex++;
  }

  @override
  Widget build(BuildContext context) {
    return _buildBoxesWithLittleLength();
  }

  _buildBox(AnswerState state, int number) {
    Color color;
    if (state == AnswerState.trueAnswer) {
      color = const Color(0xff4CAF50);
    } else if (state == AnswerState.falseAnswer) {
      color = const Color(0xffD32F2F);
    } else {
      color = const Color(0xffD9D9D9);
    }

    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: color.withOpacity(.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.w),
        shape: BoxShape.rectangle,
      ),
      child: Center(
        child: Text(
          '${number + 1}',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  _buildBoxesWithLittleLength() {
    List<Widget> children = [
      _createBullet(),
    ];

    for (var i = 0; i < _states.length; i++) {
      children.add(_createAnimatedBox(i));
    }

    return SizedBox(
      width: 375.w,
      height: 34.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: children,
      ),
    );
  }

  _createBullet() {
    return AnimatedPositioned(
      curve: _curve,
      bottom: 0,
      left: _calculateFromLeftPosition(_bulletPlaceIndex) + 7.5,
      duration: _duration,
      child: Container(
        width: 5.w,
        height: 5.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  _createAnimatedBox(int index) {
    return AnimatedPositioned(
      left: _boxesDistancesFromLeft[index],
      top: _boxesDistancesFromTop[index],
      curve: _curve,
      duration: _duration,
      child: _buildBox(_states[index], index),
    );
  }

  _doNextOperationWithoutScroll() {
    setState(() {
      if (_bulletPlaceIndex < 8) {
        _bulletPlaceIndex++;
      }

      _boxesDistancesFromTop[_currentQuestionIndex] = 6;
      _boxesDistancesFromTop[_currentQuestionIndex + 1] = 0;
    });
  }

  _calculateFromLeftPosition(int idx) {
    double startPosition = (375.w - _totalBoxesSpace) / 2;
    return startPosition + idx * 10.w + idx * 20.w;
  }
}
