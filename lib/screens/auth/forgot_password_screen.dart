import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _cargando = false;

  void _enviarCorreo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    String? error = await _authService.recuperarContrasena(_emailController.text);
    setState(() => _cargando = false);

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se ha enviado un enlace a tu correo para restablecer la contraseña.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingresa el correo asociado a tu cuenta para enviarte las instrucciones de recuperación.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) => val == null || !val.contains('@') ? 'Ingresa un correo válido' : null,
              ),
              const SizedBox(height: 24),
              _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _enviarCorreo,
                      child: const Text('ENVIAR CORREO'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}