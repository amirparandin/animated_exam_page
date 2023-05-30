import 'dart:async';

import 'package:animated_exam_page/models/StackController.dart';
import 'package:animated_exam_page/pages/ExamPage/components/AnswerState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AnswerHistoryWithMoreThan9Box extends StatefulWidget {
  const AnswerHistoryWithMoreThan9Box(
      {Key? key, required this.questionsCount, required this.stackController})
      : super(key: key);

  final int questionsCount;
  final StackController stackController;

  @override
  State<AnswerHistoryWithMoreThan9Box> createState() =>
      _AnswerHistoryWithMoreThan9BoxState();
}

class _AnswerHistoryWithMoreThan9BoxState
    extends State<AnswerHistoryWithMoreThan9Box> {
  int _currentQuestionIndex = 0;
  int _currentQuestionPlace = 0;
  int _startIndex = 0;
  late int _bulletPlaceIndex;
  late double _bulletOpacity;
  Duration _duration = const Duration(milliseconds: 500);
  final Curve _curve = Curves.linear;
  late List<double> _boxesDistancesFromLeft;
  late List<double> _boxesDistancesFromTop;
  late List<double> _boxesOpacity;
  late List<AnswerState> _states;

  @override
  void initState() {
    super.initState();

    _boxesDistancesFromLeft = [];
    _boxesDistancesFromTop = [];
    _boxesOpacity = [];
    _states = [];

    // config bullet values
    _bulletPlaceIndex = 0;
    _bulletOpacity = 1;

    for (var i = 0; i < widget.questionsCount; i++) {
      // initial state
      _states.add(AnswerState.notAnswered);

      if (i > 8) {
        // configure values of boxes that aren't visible
        _boxesOpacity.add(0);
        _boxesDistancesFromTop.add(6);
        _boxesDistancesFromLeft
            .add(AnswerHistoryUtils.calculateFromLeftPosition(8));
      } else {
        _boxesDistancesFromLeft
            .add(AnswerHistoryUtils.calculateFromLeftPosition(i));
        _boxesDistancesFromTop.add(6);
        _boxesOpacity.add(1);
      }

      // initial values for first box:
      if (i == 0) {
        _boxesDistancesFromTop[i] = 0;
      }
    }

    widget.stackController.addListener(_doNext);
  }

  _calculateCurrentQuestionPlace() {
    if (_currentQuestionIndex >= 0 && _currentQuestionIndex < 4) {
      _currentQuestionPlace++;
    } else if (_currentQuestionIndex >= widget.questionsCount - 5) {
      _currentQuestionPlace++;
    }
  }

  _didScrolled() {
    var trueStart = _currentQuestionIndex - _currentQuestionPlace;
    return trueStart != _startIndex;
  }

  void _doNext(dynamic state) {
    state = state as AnswerState;
    _states[_currentQuestionIndex] = state;

    _handleDoNextWhenScrolled();

    if (_bulletPlaceIndex == 4) {
      _doNextOperationWithScroll();
    } else {
      _doNextOperationWithoutScroll();
    }
    _calculateCurrentQuestionPlace();
    _currentQuestionIndex++;
  }

  _handleDoNextWhenScrolled() {
    if (_didScrolled()) {
      _duration = const Duration(milliseconds: 50);
      var trueStart = _currentQuestionIndex - _currentQuestionPlace;
      while (_startIndex != trueStart) {
        if (_startIndex < trueStart) {
          _doScrollToRight();
        } else {
          _doScrollToLeft();
        }
        Future.delayed(_duration);
      }
      setState(() {
        _bulletPlaceIndex = _currentQuestionPlace;
      });
      _duration = const Duration(milliseconds: 500);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBoxesWithBigLength();
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

  _buildScrollToLeftBtn() {
    if (widget.questionsCount > 10) {
      return Positioned(
        left: 10.w,
        child: IconButton(
          onPressed: () {
            _doScrollToLeft();
          },
          icon: SvgPicture.asset(
            'assets/icons/angle-left.svg',
            width: 15.w,
            height: 15.w,
            color: Colors.white,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  _buildScrollToRightBtn() {
    if (widget.questionsCount > 10) {
      return Positioned(
        right: 10.w,
        child: IconButton(
          onPressed: () {
            _doScrollToRight();
          },
          icon: SvgPicture.asset(
            'assets/icons/angle-right.svg',
            width: 15.w,
            height: 15.w,
            color: Colors.white,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  _buildBoxesWithBigLength() {
    List<Widget> children = [
      _buildScrollToRightBtn(),
      _buildScrollToLeftBtn(),
      _createBullet(),
    ];

    for (var i = 0; i < widget.questionsCount; i++) {
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
      left:
          AnswerHistoryUtils.calculateFromLeftPosition(_bulletPlaceIndex) + 7.5,
      duration: _duration,
      child: AnimatedOpacity(
        duration: _duration,
        opacity: _bulletOpacity,
        child: Container(
          width: 5.w,
          height: 5.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
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
      child: AnimatedOpacity(
        duration: _duration,
        opacity: _boxesOpacity[index],
        child: _buildBox(_states[index], index),
      ),
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

  _doNextOperationWithScroll() {
    if (_startIndex + 8 == widget.questionsCount - 1) {
      _doNextOperationWithoutScroll();
      return;
    }

    setState(() {
      //change opacity of edge boxes
      _boxesOpacity[_startIndex] = 0;
      _boxesOpacity[_startIndex + 9] = 1;

      //change left position of the boxes:
      _boxesDistancesFromLeft[_startIndex + 1] =
          AnswerHistoryUtils.calculateFromLeftPosition(0);
      _boxesDistancesFromLeft[_startIndex + 2] =
          AnswerHistoryUtils.calculateFromLeftPosition(1);
      _boxesDistancesFromLeft[_startIndex + 3] =
          AnswerHistoryUtils.calculateFromLeftPosition(2);
      _boxesDistancesFromLeft[_startIndex + 4] =
          AnswerHistoryUtils.calculateFromLeftPosition(3);
      _boxesDistancesFromLeft[_startIndex + 5] =
          AnswerHistoryUtils.calculateFromLeftPosition(4);
      _boxesDistancesFromLeft[_startIndex + 6] =
          AnswerHistoryUtils.calculateFromLeftPosition(5);
      _boxesDistancesFromLeft[_startIndex + 7] =
          AnswerHistoryUtils.calculateFromLeftPosition(6);
      _boxesDistancesFromLeft[_startIndex + 8] =
          AnswerHistoryUtils.calculateFromLeftPosition(7);

      //change top position of the boxes:

      _boxesDistancesFromTop[_startIndex + 4] = 6;
      _boxesDistancesFromTop[_startIndex + 5] = 0;
    });
    _startIndex++;
  }

  _doScrollToRight() {
    if (_startIndex + 8 >= widget.questionsCount - 1) {
      return;
    }

    setState(() {
      //change opacity of edge boxes
      _boxesOpacity[_startIndex] = 0;
      _boxesOpacity[_startIndex + 9] = 1;

      //change position of the boxes:
      _boxesDistancesFromLeft[_startIndex + 1] =
          AnswerHistoryUtils.calculateFromLeftPosition(0);
      _boxesDistancesFromLeft[_startIndex + 2] =
          AnswerHistoryUtils.calculateFromLeftPosition(1);
      _boxesDistancesFromLeft[_startIndex + 3] =
          AnswerHistoryUtils.calculateFromLeftPosition(2);
      _boxesDistancesFromLeft[_startIndex + 4] =
          AnswerHistoryUtils.calculateFromLeftPosition(3);
      _boxesDistancesFromLeft[_startIndex + 5] =
          AnswerHistoryUtils.calculateFromLeftPosition(4);
      _boxesDistancesFromLeft[_startIndex + 6] =
          AnswerHistoryUtils.calculateFromLeftPosition(5);
      _boxesDistancesFromLeft[_startIndex + 7] =
          AnswerHistoryUtils.calculateFromLeftPosition(6);
      _boxesDistancesFromLeft[_startIndex + 8] =
          AnswerHistoryUtils.calculateFromLeftPosition(7);

      //change values of bullet
      if (_startIndex == _currentQuestionIndex) {
        _bulletOpacity = 0;
      } else if (_startIndex + 9 == _currentQuestionIndex) {
        _bulletOpacity = 1;
      }

      if (_startIndex < _currentQuestionIndex &&
          _currentQuestionIndex <= _startIndex + 8) {
        _bulletPlaceIndex--;
      }
    });
    _startIndex++;
  }

  _doScrollToLeft() {
    if (_startIndex == 0) {
      return;
    }

    setState(() {
      //change opacity of edge boxes
      _boxesOpacity[_startIndex + 8] = 0;
      _boxesOpacity[_startIndex - 1] = 1;

      //change position of the boxes:
      _boxesDistancesFromLeft[_startIndex] =
          AnswerHistoryUtils.calculateFromLeftPosition(1);
      _boxesDistancesFromLeft[_startIndex + 1] =
          AnswerHistoryUtils.calculateFromLeftPosition(2);
      _boxesDistancesFromLeft[_startIndex + 2] =
          AnswerHistoryUtils.calculateFromLeftPosition(3);
      _boxesDistancesFromLeft[_startIndex + 3] =
          AnswerHistoryUtils.calculateFromLeftPosition(4);
      _boxesDistancesFromLeft[_startIndex + 4] =
          AnswerHistoryUtils.calculateFromLeftPosition(5);
      _boxesDistancesFromLeft[_startIndex + 5] =
          AnswerHistoryUtils.calculateFromLeftPosition(6);
      _boxesDistancesFromLeft[_startIndex + 6] =
          AnswerHistoryUtils.calculateFromLeftPosition(7);
      _boxesDistancesFromLeft[_startIndex + 7] =
          AnswerHistoryUtils.calculateFromLeftPosition(8);

      //change values of bullet
      if (_startIndex + 8 == _currentQuestionIndex) {
        _bulletOpacity = 0;
      } else if (_startIndex - 1 == _currentQuestionIndex) {
        _bulletOpacity = 1;
      }

      if(_startIndex <= _currentQuestionIndex && _currentQuestionIndex<_startIndex + 8){
        _bulletPlaceIndex++;
      }
    });
    _startIndex--;
  }
}

class AnswerHistoryUtils {
  static calculateFromLeftPosition(int idx) {
    return 57.5.w + idx * 10.w + idx * 20.w;
  }
}
