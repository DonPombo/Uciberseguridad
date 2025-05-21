class PasswordValidator {
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }

    if (password.length <= 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'La contraseña debe contener al menos un carácter especial (!@#\$%^&*(),.?":{}|<>)';
    }

    return null;
  }

  static String getPasswordRequirements() {
    return '''
La contraseña debe cumplir con los siguientes requisitos:
• Mínimo 8 caracteres
• Al menos una letra mayúscula
• Al menos una letra minúscula
• Al menos un número
• Al menos un carácter especial (!@#\$%^&*(),.?":{}|<>)
''';
  }
}
