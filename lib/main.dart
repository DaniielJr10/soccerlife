import 'package:flutter/material.dart';
import 'login/iniciosesion.dart'; // Importamos tu pantalla de login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soccer Life',
      theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
  useMaterial3: true,
      ),
      home: const InicioSesionPage(), // Aquí le decimos que muestre tu pantalla de login
    );
  }
}
