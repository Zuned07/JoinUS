class Validators {
  static final RegExp _passwordRegExp =
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[+\-/*_])[A-Za-z\d+\-/*_]{6,}$');

  static String? validateEmail(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Introduce un correo válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || !_passwordRegExp.hasMatch(value)) {
      return 'Debe contener una mayúscula, un número y un carácter especial permitido (+ - / * _)';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.length < 3) {
      return 'El nombre de usuario debe tener al menos 3 caracteres';
    }
    return null;
  }
}
