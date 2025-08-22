import 'package:flutter/material.dart'; // Importa todas las herramientas de Flutter (botones, textos, colores, etc.)

// Esta es tu pantalla de inicio de sesión
class InicioSesionPage extends StatelessWidget { // Crea una clase (plantilla) para tu pantalla que no cambia sola
  const InicioSesionPage({super.key}); // Constructor de la clase (se ejecuta al crear la pantalla)

  @override // Esto significa que vas a personalizar una función que ya existe
  Widget build(BuildContext context) { // Función que construye y muestra todo lo que ves en pantalla
    return Scaffold( // Estructura básica de una pantalla (como el esqueleto)
      appBar: AppBar( // Barra superior de la pantalla
        title: const Text('Soccer Life - Login'), // Texto que aparece en la barra superior
        backgroundColor: Colors.green, // Color verde para la barra superior
      ),
      body: Padding( // Contenido principal de la pantalla con espacios alrededor
        padding: const EdgeInsets.all(20.0), // Espacios de 20 puntos en todos los lados
        child: Column( // Organiza los elementos uno debajo del otro (vertical)
          mainAxisAlignment: MainAxisAlignment.center, // Centra todos los elementos verticalmente
          children: [ // Lista de elementos que van dentro de la columna
          
            // Campo para escribir el usuario
            TextField( // Caja de texto donde el usuario puede escribir
              decoration: const InputDecoration( // Decoración y estilo de la caja de texto
                labelText: 'Usuario', // Texto que aparece dentro de la caja
                border: OutlineInputBorder(), // Borde alrededor de la caja
                prefixIcon: Icon(Icons.person), // Icono de persona al inicio de la caja
              ),
            ),
            const SizedBox(height: 20), // Espacio vacío de 20 puntos de altura
            
            // Campo para escribir la contraseña
            TextField( // Segunda caja de texto para la contraseña
              decoration: const InputDecoration( // Decoración de la caja de contraseña
                labelText: 'Contraseña', // Texto que aparece dentro
                border: OutlineInputBorder(), // Borde alrededor
                prefixIcon: Icon(Icons.lock), // Icono de candado al inicio
              ),
              obscureText: true, // Esto oculta la contraseña (muestra puntitos en lugar de letras)
            ),
            const SizedBox(height: 30), // Espacio vacío de 30 puntos antes del botón
            
            // Botón para iniciar sesión
            ElevatedButton( // Botón elevado (con sombra) que se puede presionar
              onPressed: () { // Función que se ejecuta cuando presionas el botón
                // Aquí va lo que pasa cuando presionas el botón
                ScaffoldMessenger.of(context).showSnackBar( // Muestra un mensaje temporal en la parte inferior
                  const SnackBar( // El mensaje que aparece temporalmente
                    content: Text('¡Intentando iniciar sesión!'), // Texto del mensaje
                  ),
                );
              },
              style: ElevatedButton.styleFrom( // Estilo personalizado del botón
                backgroundColor: Colors.green, // Color verde para el botón
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Espacios internos del botón
              ),
              child: const Text( // Texto que aparece dentro del botón
                'ENTRAR', // Palabra que se muestra en el botón
                style: TextStyle(fontSize: 16, color: Colors.white), // Tamaño y color del texto
              ),
            ),
          ],
        ),
      ),
    );
  }
}
