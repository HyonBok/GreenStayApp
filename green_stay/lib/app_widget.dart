import 'package:flutter/material.dart';
import 'package:green_stay/login_widget.dart';

class GreenStayApp extends StatelessWidget {
  const GreenStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Stay App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(76, 175, 80, 1)),
      ),
      home: const LoginPage(),
    );
  }
}

