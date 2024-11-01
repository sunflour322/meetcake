import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color.fromRGBO(255, 159, 159, 1),
  scaffoldBackgroundColor: Color.fromRGBO(255, 159, 159, 1),
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromRGBO(255, 159, 159, 1),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        foregroundColor: Color.fromRGBO(
          255,
          159,
          159,
          1,
        ),
        textStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16) // Цвет текста ElevatedButton в темной теме
        ),
  ),
  textTheme: TextTheme(
      // bodyText1: TextStyle(color: Colors.black, fontSize: 16),
      // bodyText2: TextStyle(color: Colors.grey[700]),
      ),
);
