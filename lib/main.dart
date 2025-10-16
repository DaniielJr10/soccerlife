import 'package:flutter/material.dart';
import 'login/iniciosesion.dart'; // Importacion pantalla de login

/// Esta función inicializa la aplicación Flutter y configura el widget raíz.
/// La aplicación comienza mostrando la pantalla de inicio de sesión.
void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación Soccer Life

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //  CONFIGURACIÓN BÁSICA DE LA APP 
      title: 'Soccer Life',

      //  CONFIGURACIÓN DEL TEMA 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      // ===== RUTAS DE LA APP =====
      initialRoute: '/login',
      routes: {
        '/login': (context) => const InicioSesionPage(),
        
      },

      //  CONFIGURACIONES ADICIONALES
      debugShowCheckedModeBanner: false,
    );
  }
}
