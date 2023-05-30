import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class CongCard extends StatefulWidget {
  const CongCard({Key? key, required this.animationController})
      : super(key: key);
  final AnimationController animationController;

  @override
  State<CongCard> createState() => _CongCardState();
}

class _CongCardState extends State<CongCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    widget.animationController.addListener(() {
      setState(() {});
      if (widget.animationController.value >= .8 &&
          (_lottieController.status != AnimationStatus.forward)) {
        _lottieController.forward();
      }
    });
    _lottieController = AnimationController(vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350.w,
      height: 561.h,
      padding: EdgeInsets.fromLTRB(25.w, 50.h, 25.w, 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0xffF5F4F6),
      ),
      child: Stack(
        children: [
          Lottie.asset('assets/lotties/cong_anim.json',
              controller: _lottieController, onLoaded: (composition) {
            _lottieController.duration = composition.duration;
            // ..forward();
          }),
          _buildMainBtn(),
          _buildSecondBtn(),
        ],
      ),
    );
  }

  _buildMainBtn() {
    return Positioned(
      bottom: (widget.animationController.value != 0)
          ? CongCardAnimations.moveUpMainBtnAnimation(widget.animationController)
              .value
          : 100.h,
      child: Opacity(
        opacity: (widget.animationController.value != 0)
            ? CongCardAnimations.showMainBtnAnimation(widget.animationController)
                .value
            : 0,
        child: ElevatedButton(
          onPressed: () {
            _lottieController.forward();
          },
          style: ElevatedButton.styleFrom(
              primary: const Color(0xff5B38AD),
              onPrimary: Colors.white,
              fixedSize: Size(300.w, 58.w),
              elevation: 10,
              shadowColor: const Color(0xff5B38AD).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32))),
          child: Text(
            'Countinue lesson',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildSecondBtn() {
    return Positioned(
      bottom: (widget.animationController.value == 0)
          ? CongCardAnimations.moveUpSecondaryBtnAnimation(widget.animationController)
              .value
          : 20.h,
      child: Opacity(
        opacity: (widget.animationController.value != 0)
            ? CongCardAnimations.showSecondaryBtnAnimation(widget.animationController)
                .value
            : 0,
        child: ElevatedButton(
          onPressed: () {
            _lottieController.forward();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            fixedSize: Size(300.w, 55.w),
            elevation: 10,
            shadowColor: const Color(0xff5B38AD).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: const BorderSide(
                color: Color(0xff5B38AD),
              ),
            ),
          ),
          child: Text(
            'Take exam again',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff5B38AD),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CongCardAnimations {
  static Animation<double> moveUpMainBtnAnimation(
      AnimationController animationController) {
    return Tween<double>(
      begin: 0,
      end: 100.h,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          .8,
          .9,
        ),
      ),
    );
  }

  static Animation<double> moveUpSecondaryBtnAnimation(
      AnimationController animationController) {
    return Tween<double>(
      begin: 0,
      end: 20.h,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          .9,
          1,
        ),
      ),
    );
  }

  static Animation<double> showMainBtnAnimation(
      AnimationController animationController) {
    return Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          .8,
          .9,
        ),
      ),
    );
  }

  static Animation<double> showSecondaryBtnAnimation(
      AnimationController animationController) {
    return Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          .9,
          1,
        ),
      ),
    );
  }
}
