import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportBox extends StatefulWidget {
  const ReportBox(
      {Key? key,
      required this.draggableScrollableController,
      required this.title,
      required this.definitions})
      : super(key: key);
  final DraggableScrollableController draggableScrollableController;
  final String title;
  final String definitions;

  @override
  State<ReportBox> createState() => _ReportBoxState();
}

class _ReportBoxState extends State<ReportBox> {
  late final List<String> _reasons = [];
  bool _enableMessageBox = false;

  // this message will sent when btn clicked
  String _message = '';
  int? _groupValue = 0;

  @override
  void initState() {
    // this reasons received from the server
    _reasons.add('Not related to the content');
    _reasons.add('Punctuation mistake');
    _reasons.add('Grammatical mistake');
    _reasons.add('Very difficult for this level');
    // this reason adds programmatically
    _reasons.add('Other');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _makeDismissible(
      DraggableScrollableSheet(
        initialChildSize: .7,
        maxChildSize: .7,
        minChildSize: .5,
        controller: widget.draggableScrollableController,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xffECE6F6).withOpacity(.5),
                  blurRadius: 32,
                  spreadRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildChildren(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _buildChildren() {
    List<Widget> children = [];
    children.add(_buildHandle());
    children.add(_buildTitle());
    children.add(_buildDefinitions());
    List<Widget> reasonsAsWidget = [];
    for (var i = 0; i < _reasons.length; i++) {
      reasonsAsWidget.add(_buildReason(_reasons[i], i));
      if(i!= _reasons.length - 1){
        reasonsAsWidget.add(
          Divider(
            color: const Color(0xffD9D9D9),
            height: 3.h,
          ),
        );
      }
    }
    reasonsAsWidget.add(
      _buildMessageBox(),
    );
    children.add(
      SizedBox(
        height: 260.h,
        child: ListView(
          children: reasonsAsWidget,
        ),
      ),
    );

    children.add(_buildBtn());
    return children;
  }

  _buildBtn() {
    return Padding(
      padding: EdgeInsets.only(left: 25.w, right: 25.w, top: 50.h),
      child: ElevatedButton(
        onPressed: () {

          // if oder reason not selected an empty message will sent
          if(_groupValue != _reasons.length - 1){
            _message = '';
          }

          // close bottom sheet
          Navigator.of(context).pop();

        },
        style: ElevatedButton.styleFrom(
          primary: const Color(0xff5B38AD),
          onPrimary: Colors.white,
          fixedSize: Size(328.w, 52.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          shadowColor: const Color(0xff5B38AD).withOpacity(.45),
        ),
        child: Text(
          'Submit',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _buildHandle() {
    return Container(
      height: 4.h,
      margin: EdgeInsets.symmetric(horizontal: 165.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Color(0xffD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 25.w, top: 10.h, bottom: 10.h),
      child: Text(
        widget.title,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  _buildDefinitions() {
    return Padding(
      padding:
          EdgeInsets.only(left: 25.w, top: 10.h, right: 25.w, bottom: 20.h),
      child: Text(
        widget.definitions,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  _makeDismissible(Widget child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      );

  _buildReason(String title, int val) {
    return RadioListTile(
      title: Text(
        title,
        style: GoogleFonts.roboto(
            textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        )),
      ),
      value: val,
      groupValue: _groupValue,
      onChanged: (int? value) {
        setState(() {
          _groupValue = value;
          if(value == _reasons.length - 1){
            _enableMessageBox = true;
          }else{
            _enableMessageBox = false;
          }
        });
      },
      activeColor: Color(0xff5B38AD),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
    );
  }

  Widget _buildMessageBox() {
    return Opacity(
      opacity: _enableMessageBox ? 1 : .6,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          border: Border.all(color: const Color(0xffD9D9D9)),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.only(right: 25.w, left: 45.w, top: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: _createTextField(),
      ),
    );
  }

  _createTextField() {
    return TextField(
      autofocus: true,
      readOnly: !_enableMessageBox,
      minLines: 1,
      maxLines: 7,
      onChanged: (String value){
        _message = value;
      },
      decoration: InputDecoration(

        hintText: 'Type your message here...',
        disabledBorder: InputBorder.none,
        border: InputBorder.none,
        hintStyle: GoogleFonts.roboto(
          textStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
            color: const Color(0xff616161),
          ),
        ),
      ),
    );
  }
}
