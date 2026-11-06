import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro de usuario + guardar nombre en Firestore
  Future<String?> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Crear usuario en Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 2. Guardar datos adicionales en Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'nombre': nombre.trim(),
          'email': email.trim(),
          'photoUrl': '', // Inicia sin foto personalizada
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null; // Null significa sin errores
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Este correo electrónico ya está registrado.';
      } else if (e.code == 'weak-password') {
        return 'La contraseña debe tener al menos 6 caracteres.';
      } else if (e.code == 'invalid-email') {
        return 'El formato del correo no es válido.';
      }
      return e.message ?? 'Error al registrar el usuario.';
    } catch (e) {
      return 'Ocurrió un error inesperado.';
    }
  }

  // Inicio de sesión
  Future<String?> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Correo o contraseña incorrectos.';
      }
      return 'Error al iniciar sesión: ${e.message}';
    } catch (e) {
      return 'Error inesperado al iniciar sesión.';
    }
  }

  // Recuperar contraseña por correo
  Future<String?> recuperarContrasena(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No existe una cuenta registrada con este correo.';
      }
      return 'Error al enviar el correo de recuperación.';
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}