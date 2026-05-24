import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const GSVSportsApp());
}

class GSVSportsApp extends StatelessWidget {
  const GSVSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSV Sports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginPage(),
    );
  }
}
