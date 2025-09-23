import 'package:flutter/material.dart';
import 'login/iniciosesion.dart'; // Importamos la pantalla de login

/// Punto de entrada principal de la aplicación Soccer Life
/// 
/// Esta función inicializa la aplicación Flutter y configura el widget raíz.
/// La aplicación comienza mostrando la pantalla de inicio de sesión.
void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación Soccer Life
/// 
/// Configura el tema global, título de la aplicación y la pantalla inicial.
/// Utiliza Material Design 3 con una paleta de colores basada en verde.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ===== CONFIGURACIÓN BÁSICA DE LA APP =====
      title: 'Soccer Life',
      
      // ===== CONFIGURACIÓN DEL TEMA =====
      theme: ThemeData(
        // Paleta de colores basada en verde (color del fútbol)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        // Usar Material Design 3 para componentes modernos
        useMaterial3: true,
      ),
      
      // ===== PANTALLA INICIAL =====
      // La aplicación comienza con la pantalla de inicio de sesión
      home: const InicioSesionPage(),
      
      // ===== CONFIGURACIONES ADICIONALES =====
      // Ocultar el banner de debug en la esquina superior derecha
      debugShowCheckedModeBanner: false,
    );
  }
}
