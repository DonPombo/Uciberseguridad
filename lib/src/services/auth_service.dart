import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final _supabase = supabase.Supabase.instance.client;

  // Obtener el usuario actual
  User? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return User.fromSupabaseUser(user);
  }

  // Registro
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('Iniciando registro de usuario...');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': 'student',
        },
      );

      debugPrint('Respuesta de registro recibida');
      if (response.user != null) {
        debugPrint('Usuario registrado exitosamente');
        return User.fromSupabaseUser(response.user!);
      }
      return null;
    } catch (e) {
      debugPrint('Error en registro: $e');
      throw _handleError(e);
    }
  }

  // Login
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Iniciando inicio de sesión...');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      debugPrint('Respuesta de inicio de sesión recibida');
      if (response.user != null) {
        debugPrint('Inicio de sesión exitoso');
        return User.fromSupabaseUser(response.user!);
      }
      return null;
    } catch (e) {
      debugPrint('Error en inicio de sesión: $e');
      throw _handleError(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      debugPrint('Cerrando sesión...');
      await _supabase.auth.signOut();
      debugPrint('Sesión cerrada exitosamente');
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      throw _handleError(e);
    }
  }

  // Manejo de errores mejorado
  String _handleError(dynamic error) {
    debugPrint('Manejando error: $error');
    if (error is supabase.AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Correo o contraseña incorrectos';
        case 'User already registered':
          return 'Este correo ya está registrado';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return 'Error inesperado: $error';
  }

  // Método para verificar si el usuario es admin
  Future<bool> isUserAdmin() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] == 'admin';
    } catch (e) {
      debugPrint('Error verificando rol: $e');
      return false;
    }
  }

  // Método para verificar si el usuario es estudiante
  Future<bool> isUserStudent() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] == 'student';
    } catch (e) {
      debugPrint('Error verificando rol: $e');
      return false;
    }
  }

  // Método genérico para verificar cualquier rol
  Future<bool> hasRole(String role) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] == role;
    } catch (e) {
      debugPrint('Error verificando rol: $e');
      return false;
    }
  }

  // Método para obtener el rol actual del usuario
  Future<String?> getCurrentUserRole() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'];
    } catch (e) {
      debugPrint('Error obteniendo rol: $e');
      return null;
    }
  }

  // Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('Iniciando cambio de contraseña...');

      // Primero verificamos que la contraseña actual sea correcta
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw 'No hay usuario autenticado';
      }

      // Intentamos iniciar sesión con la contraseña actual para verificarla
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      // Si llegamos aquí, la contraseña actual es correcta
      // Ahora actualizamos la contraseña
      await _supabase.auth.updateUser(
        supabase.UserAttributes(
          password: newPassword,
        ),
      );

      debugPrint('Contraseña actualizada exitosamente');
    } catch (e) {
      debugPrint('Error al cambiar la contraseña: $e');
      if (e.toString().contains('Invalid login credentials')) {
        throw 'La contraseña actual es incorrecta';
      }
      throw _handleError(e);
    }
  }
}
