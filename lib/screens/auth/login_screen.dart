import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../main_navigator.dart';

// =====================================================================
// PALETA DE COLORES TEQUANI
// =====================================================================
const Color obsidianBlack = Color(0xFF14110F);
const Color deepJadeGreen = Color(0xFF1B4D3E);
const Color tezontleRed   = Color(0xFF7A1C1C);
const Color ochreGold     = Color(0xFFC29B38);
const Color amatePaper    = Color(0xFFE5D4C0);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _cargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    String? error = await _authService.iniciarSesion(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: const TextStyle(color: amatePaper)),
          backgroundColor: tezontleRed,
        ),
      );
    } else {
      // Transición visual suave al acceder a la pantalla principal
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, _, _) => const MainNavigator(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO OFICIAL DE TEQUANI CON ANIMACIÓN DE ENTRADA
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.85 + (0.15 * value),
                            child: child,
                          ),
                        );
                      },
                      child: Center(
                        child: Container(
                          width: 115,
                          height: 115,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: obsidianBlack,
                            border: Border.all(color: ochreGold, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: tezontleRed.withValues(alpha: 0.45),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.shield_moon,
                                size: 60,
                                color: ochreGold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TÍTULO ADAPTABLE A CUALQUIER ANCHO DE PANTALLA
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'COMUNIDAD TEQUANI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ochreGold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Inicia sesión para unirte a los guerreros',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: amatePaper.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // CAMPO DE CORREO ELECTRÓNICO
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: amatePaper),
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: const TextStyle(color: ochreGold),
                        prefixIcon: const Icon(Icons.email_outlined, color: ochreGold),
                        filled: true,
                        fillColor: deepJadeGreen.withValues(alpha: 0.2),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: deepJadeGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: ochreGold, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: tezontleRed),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: tezontleRed, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa tu correo obligatorio';
                        }
                        if (!val.contains('@')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CAMPO DE CONTRASEÑA CON BOTÓN PARA MOSTRAR/OCULTAR
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarPassword,
                      style: const TextStyle(color: amatePaper),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: ochreGold),
                        prefixIcon: const Icon(Icons.lock_outline, color: ochreGold),
                        suffixIcon: IconButton(
                          tooltip: 'Mostrar u ocultar contraseña',
                          icon: Icon(
                            _ocultarPassword ? Icons.visibility_off : Icons.visibility,
                            color: ochreGold,
                          ),
                          onPressed: () {
                            setState(() => _ocultarPassword = !_ocultarPassword);
                          },
                        ),
                        filled: true,
                        fillColor: deepJadeGreen.withValues(alpha: 0.2),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: deepJadeGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: ochreGold, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: tezontleRed),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: tezontleRed, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Ingresa tu contraseña obligatoria' : null,
                    ),

                    // BOTÓN DE RECUPERAR CONTRASEÑA
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: ochreGold, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // BOTÓN PRINCIPAL DE INICIAR SESIÓN CON ANIMACIÓN DE CARGA
                    _cargando
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(color: ochreGold),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tezontleRed,
                              foregroundColor: amatePaper,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _iniciarSesion,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'INICIAR SESIÓN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 12),

                    // BOTÓN DE CREAR NUEVA CUENTA
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ochreGold,
                        side: const BorderSide(color: ochreGold, width: 1.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'CREAR NUEVA CUENTA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}