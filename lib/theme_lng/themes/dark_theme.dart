import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    primaryColorLight: Color.fromRGBO(255, 159, 159, 1),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
        // bodyText1: TextStyle(color: Colors.white, fontSize: 16),
        // bodyText2: TextStyle(color: Colors.grey[300]),
        // labelLarge: TextStyle(
        //     color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),
        // labelMedium: TextStyle(
        //     color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),
        // labelSmall: TextStyle(
        //     color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16)),
        ));
