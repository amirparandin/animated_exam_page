
import 'package:animated_exam_page/pages/ExamPage/ExamPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 809),
      builder: (context, child) {
        return MaterialApp(
          home: child,
          debugShowCheckedModeBanner: false,
        );
      },
      child:  Scaffold(
        body: ExamPage(),
      ),
    ),
  );
}
