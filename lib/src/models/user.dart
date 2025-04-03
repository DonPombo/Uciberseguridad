import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'student',
  });

  factory User.fromSupabaseUser(supabase.User user) {
    return User(
      id: user.id,
      name: user.userMetadata?['name'] ?? '',
      email: user.email ?? '',
      role: user.userMetadata?['role'] ?? 'student',
    );
  }

  // Método para convertir a Map para Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
