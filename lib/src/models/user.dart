enum UserRole { student, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.student, // Por defecto, todos son estudiantes
  });

  // Factory constructor para crear un User desde Supabase
  factory User.fromSupabase(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.student,
    );
  }

  // Método para convertir a Map para Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'student',
    };
  }
}
