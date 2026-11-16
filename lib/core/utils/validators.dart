// The rules the server enforces, checked here too so the user reads them in
// Arabic and before a round trip. Keep them in step with the API:
// activation.service.js (passwords) and user.controller.js (email).

/// bcrypt ignores anything past 72 bytes, so the server refuses longer.
/// Arabic letters take two bytes each, so this is reachable in practice.
const _maxPasswordBytes = 72;

/// Counts what the server counts: UTF-8 bytes, not characters.
int _utf8Length(String value) {
  var bytes = 0;
  for (final rune in value.runes) {
    bytes += switch (rune) {
      < 0x80 => 1,
      < 0x800 => 2,
      < 0x10000 => 3,
      _ => 4,
    };
  }
  return bytes;
}

/// What is wrong with [password], or null if the server will take it.
String? passwordProblem(String password) {
  if (password.length < 8) return 'كلمة المرور 8 أحرف على الأقل.';
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'[0-9]').hasMatch(password)) {
    return 'كلمة المرور يجب أن تحتوي على حرف ورقم.';
  }
  if (_utf8Length(password) > _maxPasswordBytes) {
    return 'كلمة المرور طويلة جداً.';
  }
  return null;
}

/// The same shape the server accepts: something@something.something.
final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

bool isValidEmail(String value) => _email.hasMatch(value);
