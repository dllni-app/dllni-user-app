import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();
  static final ThemeData light = ThemeData(
    fontFamily: "Cairo",
    scaffoldBackgroundColor: Color(0xFFEFEFEF),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        color: AppColors.hintText,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1E2A78),
      onPrimary: Color(0xffFFFFFF),
      secondary: Color(0xff6C63FF),
      onSecondary: Color(0xffFFFFFF),
      error: Color(0xffBF393D),
      onError: Color(0xffFFFFFF),
      surface: Color(0xffF0F0F0),
      onSurface: Color(0xffFFFFFF),
      primaryContainer: Color(0xffFF7A00),
      onPrimaryContainer: Color(0xffFFFFFF),
    ),
    // colorScheme: ColorScheme(
    //   brightness: Brightness.light,
    //   primary: Color(0xff1E2A78),
    //   onPrimary: Color(0xffFFFFFF),
    //   secondary: Color(0xff6C63FF),
    //   onSecondary: Color(0xffFFFFFF),
    //   error: Color(0xffBF393D),
    //   onError: Color(0xffFFFFFF),
    //   surface: Color(0xffEFEFEF),
    //   onSurface: Color(0xffFFFFFF),
    //   primaryContainer: Color(0xffFF7A00),
    //   onPrimaryContainer: Color(0xffFFFFFF),
    // ),
  );
}
