import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color.fromRGBO(255, 159, 159, 1),
  primaryColorLight: Colors.black,
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
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
        color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
    suffixIconColor: Colors.white,
    border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 3)),
    focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 3)),
    enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 3)),
  ),
  textTheme: TextTheme(
      // bodyText1: TextStyle(color: Colors.black, fontSize: 16),
      // bodyText2: TextStyle(color: Colors.grey[700]),
      ),
);
