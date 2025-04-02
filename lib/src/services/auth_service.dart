import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uciberseguridad_app/src/models/user.dart';

class AuthService {
  final _supabase = supabase.Supabase.instance.client;

  // Obtener el usuario actual
  User? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    // TODO: Aquí podrías obtener los datos adicionales del usuario desde la tabla users
    return User(
      id: user.id,
      email: user.email!,
      name: user.userMetadata?['name'] ?? '',
    );
  }

  // Registro
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        // Crear el perfil del usuario en la tabla users
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'role': 'student',
        });

        return User(
          id: response.user!.id,
          name: name,
          email: email,
        );
      }
      return null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Login
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        return User.fromSupabase(userData);
      }
      return null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Manejo de errores
  String _handleError(dynamic error) {
    if (error is supabase.AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Credenciales inválidas';
        case 'Email not confirmed':
          return 'Por favor confirma tu correo electrónico';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return 'Error inesperado: $error';
  }
}
