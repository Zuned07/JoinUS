class Validators {
  static final RegExp _uppercaseRegExp = RegExp(r'[A-Z]');
  static final RegExp _numberRegExp = RegExp(r'\d');
  static final RegExp _specialCharRegExp = RegExp(r'[+\-/*_]');
  static final int _minLength = 6;

  static String? validateEmail(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Introduce un correo válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null) {
      return 'La contraseña no puede estar vacía';
    }
    List<String> errors = [];

    if (value.length < _minLength) {
      errors.add('Debe tener al menos $_minLength caracteres');
    }
    if (!_uppercaseRegExp.hasMatch(value)) {
      errors.add('Falta una letra mayúscula');
    }
    if (!_numberRegExp.hasMatch(value)) {
      errors.add('Falta un número');
    }
    if (!_specialCharRegExp.hasMatch(value)) {
      errors.add('Falta un carácter especial (+ - / * _)');
    }

    if (errors.isEmpty) {
      return null;
    } else {
      return errors.join('\n');
    }
  }

  static String? validateUsername(String? value) {
    if (value == null || value.length < 3) {
      return 'El nombre de usuario debe tener al menos 3 caracteres';
    }
    return null;
  }
}
