import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'utils/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de inicializar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase con las opciones generadas por CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foro Gamer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Aplica tu paleta Obsidian Black, Tezontle Red y Ochre Gold
      home: StreamBuilder<User?>(
        // Escucha los cambios en el estado de autenticación de Firebase
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Mientras verifica el estado del usuario, muestra pantalla de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Si hay una sesión activa, entra temporalmente a la pantalla principal
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Foro del Juego'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sports_esports,
                      size: 80,
                      color: Color(0xFFC29B38), // Ochre Gold
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '¡Bienvenido, Gamer!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sesión iniciada como: ${snapshot.data!.email}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Si el usuario no está autenticado, lo manda a la pantalla de Login
          return const LoginScreen();
        },
      ),
    );
  }
}