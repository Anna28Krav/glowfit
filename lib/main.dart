import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';

void main() {
  runApp(const GlowFitApp());
}

class GlowFitApp extends StatelessWidget {
  const GlowFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlowFit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const RegistrationScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
