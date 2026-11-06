import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _cargando = false;

  void _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    String? error = await _authService.registrarUsuario(
      nombre: _nombreController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _cargando = false);

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta creada exitosamente!')),
      );
      Navigator.pop(context); // Regresa al Login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Jugador')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.sports_esports, size: 70, color: Color(0xFFC29B38)), // Ochre Gold[cite: 1]
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario / Gamertag',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                  if (!val.contains('@')) return 'Ingresa un correo válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingresa una contraseña';
                  if (val.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registrar,
                      child: const Text('CREAR CUENTA'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}