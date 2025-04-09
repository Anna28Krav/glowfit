import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlowFit',
      home: Scaffold(
        appBar: AppBar(title: Text('GlowFit')),
        body: Center(child: Text('Привіт, GlowFit працює!')),
      ),
    );
  }
}
