import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:me_recipe/screens/home.dart';
import 'package:me_recipe/utility/get_it_locator.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MeRecipe",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFFBE6),
        colorScheme: ColorScheme.light().copyWith(
          primary: const Color(0xFF356859),
          background: const Color(0xFFFFFBE6),
          secondary: const Color(0xFFFD5523),
        ),
      ),
      home: const Home(),
    );
  }
}
