import 'package:flutter/material.dart';
import 'package:eco_dive_ai/pages/home_page.dart'; // 홈 페이지 임포트
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(EcoDiveAIApp());
}

class EcoDiveAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoDive AI',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue, // 상수로 이동 가능
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            foregroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            foregroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: EcoDiveHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}