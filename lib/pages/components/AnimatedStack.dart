import 'package:animated_exam_page/pages/ExamPage/components/AnswerState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/StackController.dart';

Size? backCardSize = Size(308.w, 585.h);
Size? middleCardSize = Size(328.w, 585.h);
Size? topCardFirstSize = Size(300.w, 560.h);
Size? topCardLastSize = Size(350.w, 585.h);

class AnimatedStack extends StatefulWidget {
  const AnimatedStack({
    Key? key,
    required this.stackController,
    required this.cards,
    this.duration = 1,
    this.isReversed = false,
  }) : super(key: key);

  final StackController stackController;
  final bool isReversed;
  final List<Widget> cards;
  final int duration;

  @override
  State<AnimatedStack> createState() => _AnimatedStackState();
}

class _AnimatedStackState extends State<AnimatedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Widget> _cards;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool _swipeSoundEffectPlayed = false;

  @override
  void initState() {
    if (widget.isReversed) {
      _cards = widget.cards.reversed.toList();
    } else {
      _cards = widget.cards;
    }

    widget.stackController.addListener(_animate);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cards.removeLast();
        _swipeSoundEffectPlayed = false;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _topCard() {
    return _cards[_cards.length - 1];
  }

  Widget _inCard() {
    return _cards[_cards.length - 2];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.w,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          _buildBackCardSimulator(),
          _buildBackCardSimulatorDisappearAnimation(),
          _buildMiddleCardSimulator(),
          _buildMiddleCardSimulatorDisappearAnimation(),
          _showMiddleToTopAnimation(),
          _showTopCard(),
          _moveFrontCardToDown(),
          _moveFrontCardOut(),
        ],
      ),
    );
  }

  _buildBackCardSimulator() {
    Size? size = backCardSize;
    if (_animationController.status == AnimationStatus.forward) {
      if (_cards.length == 3) return const SizedBox();
    }
    if (_cards.length >= 3) {
      return Positioned(
        top: 22.h,
        child: SizedBox.fromSize(
          size: size,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xffF5F4F6).withOpacity(.5),
              borderRadius: BorderRadius.circular(35),
            ),
          ),
        ),
      );
    }
    return SizedBox();
  }

  _buildBackCardSimulatorDisappearAnimation() {
    if (_animationController.status == AnimationStatus.forward) {
      if (_cards.length == 3) {
        return Positioned(
          top: CardAnimations.backCardSimulatorPositionedAnimation(
                  _animationController)
              .value,
          child: SizedBox.fromSize(
            size: CardAnimations.backCardSimulatorSizeAnimation(
                    _animationController)
                .value,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffF5F4F6).withOpacity(.5),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
        );
      }
    }
    return SizedBox();
  }

  _buildMiddleCardSimulator() {
    if (_animationController.status == AnimationStatus.forward) {
      if (_cards.length == 3 || _cards.length == 2) return const SizedBox();
    }
    if (_cards.length >= 3 || _cards.length == 2) {
      return Positioned(
        top: 11.h,
        child: SizedBox.fromSize(
          size: middleCardSize,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xffF5F4F6).withOpacity(.5),
              borderRadius: BorderRadius.circular(35),
            ),
          ),
        ),
      );
    }
    return SizedBox();
  }

  _buildMiddleCardSimulatorDisappearAnimation() {
    if (_animationController.status == AnimationStatus.forward) {
      if (_cards.length == 3) {
        return Positioned(
          top: CardAnimations.middleCardSimulatorPositionedAnimation(
                  _animationController)
              .value,
          child: Opacity(
            opacity: CardAnimations.middleCardSimulatorOpacityAnimation(
                    _animationController)
                .value,
            child: Container(
              width: 328.w,
              height: 585.h,
              decoration: BoxDecoration(
                color: const Color(0xffF5F4F6).withOpacity(.5),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
        );
      } else if (_cards.length == 2) {
        return Positioned(
          top: CardAnimations.convertMiddleCardSimToTopCardPositionedAnimation(
                  _animationController)
              .value,
          child: SizedBox.fromSize(
            size: CardAnimations.convertMiddleCardSimToTopCardSizeAnimation(
                    _animationController)
                .value,
            child: Opacity(
              opacity:
                  CardAnimations.convertMiddleCardSimToTopCardOpacityAnimation(
                          _animationController)
                      .value,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffF5F4F6),
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
            ),
          ),
        );
      }
    }
    return SizedBox();
  }

  _showMiddleToTopAnimation() {
    Size? size;
    double opacity;
    double top;
    if (_animationController.status == AnimationStatus.forward) {
      _playSoundEffect();
      size = CardAnimations.realMiddleCardSizeAnimation(_animationController)
          .value;
      opacity =
          CardAnimations.realMiddleCardOpacityAnimation(_animationController)
              .value;
      top =
          CardAnimations.realMiddleCardPositionedAnimation(_animationController)
              .value;
      return Positioned(
        top: top,
        child: Opacity(
          opacity: opacity,
          child: SizedBox.fromSize(
            size: size,
            child: _inCard(),
          ),
        ),
      );
    }
    return SizedBox();
  }

  _showTopCard() {
    if (_animationController.status != AnimationStatus.forward) {
      return SizedBox.fromSize(
        size: topCardLastSize,
        child: _topCard(),
      );
    }
    return SizedBox();
  }

  _moveFrontCardToDown() {
    if (_animationController.value <= 0.2) {
      if (_animationController.status == AnimationStatus.forward) {
        double top = CardAnimations.frontCardMoveDownVerticalAnimation(
                _animationController)
            .value;
        double left = CardAnimations.frontCardMoveDownHorizontalAnimation(
                _animationController)
            .value;
        return Positioned(
          top: top,
          left: left,
          child: SizedBox.fromSize(
            size: topCardLastSize,
            child: _topCard(),
          ),
        );
      }
    }
    return SizedBox();
  }

  _playSoundEffect() async {
    if (!_swipeSoundEffectPlayed) {
      _swipeSoundEffectPlayed = true;
      await audioPlayer.setAsset('assets/audios/swipe_sound.mp3');
      await audioPlayer.setVolume(.5);
      await audioPlayer.play();
    }
  }

  _moveFrontCardOut() {
    if (_animationController.value > 0.2) {
      if (_animationController.status == AnimationStatus.forward) {
        double top = CardAnimations.frontCardMoveOutVerticalAnimation(
                _animationController)
            .value;
        double left = CardAnimations.frontCardMoveOutHorizontalAnimation(
                _animationController)
            .value;
        return Positioned(
          top: top,
          left: left,
          child: Opacity(
            opacity:
                CardAnimations.frontCardOpacityAnimation(_animationController)
                    .value,
            child: Transform.rotate(
              angle:
                  CardAnimations.frontCardRotateAnimation(_animationController)
                      .value,
              child:  SizedBox.fromSize(
                size: topCardLastSize,
                child: _topCard(),
              ),
            ),
          ),
        );
      }
    }
    return SizedBox();
  }

  _animate(dynamic state) {
    state = state as AnswerState;
    if (_animationController.status == AnimationStatus.forward) {
      _animationController.stop();
      _swipeSoundEffectPlayed = false;
      _cards.removeLast();
    }
    _animationController.value = 0.0;
    _animationController.forward();
  }
}

class CardAnimations {
  static Animation<Size?> backCardSimulatorSizeAnimation(
      AnimationController controller) {
    return Tween<Size>(begin: backCardSize, end: middleCardSize).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.5,
          1,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  static Animation<double> backCardSimulatorPositionedAnimation(
      AnimationController controller) {
    return Tween<double>(begin: 22.h, end: 11.h).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.5,
          1,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  static Animation<double> middleCardSimulatorPositionedAnimation(
      AnimationController controller) {
    return Tween<double>(begin: 11.h, end: 0.h).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0,
          0.5,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  static Animation<double> middleCardSimulatorOpacityAnimation(
      AnimationController controller) {
    return Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0,
          0.3,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  static Animation<Size?> realMiddleCardSizeAnimation(
      AnimationController controller) {
    return SizeTween(begin: topCardFirstSize, end: topCardLastSize).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0,
          0.4,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  static Animation<double> realMiddleCardOpacityAnimation(
      AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0,
          0.7,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  static Animation<double> realMiddleCardPositionedAnimation(
      AnimationController controller) {
    return Tween<double>(begin: -10.h, end: 0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0,
          0.7,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  static Animation<double> convertMiddleCardSimToTopCardPositionedAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 11.h, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0,
          0.5,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  static Animation<Size?> convertMiddleCardSimToTopCardSizeAnimation(
      AnimationController animationController) {
    return Tween<Size>(begin: middleCardSize, end: topCardLastSize).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0,
          0.5,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  static Animation<double> convertMiddleCardSimToTopCardOpacityAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: .5, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0,
          0.7,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  static Animation<double> frontCardMoveDownVerticalAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 0, end: 60.h).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0,
          0.2,
          curve: Curves.easeOutSine,
        ),
      ),
    );
  }

  static Animation<double> frontCardMoveDownHorizontalAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 0, end: -20.w).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0,
          0.2,
          curve: Curves.easeOutSine,
        ),
      ),
    );
  }

  static Animation<double> frontCardMoveOutVerticalAnimation(
      AnimationController animationController) {
    return Tween(begin: 60.h, end: -40.h).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.21,
          .8,
          curve: Curves.easeOutSine,
        ),
      ),
    );
  }

  static Animation<double> frontCardMoveOutHorizontalAnimation(
      AnimationController animationController) {
    return Tween(begin: -20.w, end: -400.w).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.21,
          .8,
          curve: Curves.easeOutSine,
        ),
      ),
    );
  }

  static Animation<double> frontCardRotateAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 0.0, end: .1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.21,
          0.8,
          curve: Curves.easeInBack,
        ),
      ),
    );
  }

  static Animation<double> frontCardOpacityAnimation(
      AnimationController animationController) {
    return Tween<double>(begin: 0.9, end: 0.5).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.6,
          0.9,
          curve: Curves.easeInBack,
        ),
      ),
    );
  }
}
