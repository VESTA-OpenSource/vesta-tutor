class Validators {
  /// Valida el formato del correo electrónico.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Valida el nombre de usuario: 
  /// - 6 a 20 caracteres.
  /// - Alfanuméricos, puntos o guiones bajos.
  static bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]{6,20}$');
    return usernameRegex.hasMatch(username);
  }

  /// Valida la complejidad de la contraseña:
  /// - Mínimo 8 caracteres.
  /// - Al menos una letra mayúscula.
  /// - Al menos una letra minúscula.
  /// - Al menos un número.
  /// - Al menos un carácter especial (!@#$%^&*(),.?":{}|<>).
  static bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(password);
  }
}