import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_managemnt_app/core/utils/validators.dart';

void main() {
  group('password', () {
    test('accepts what the server accepts', () {
      expect(passwordProblem('Secret123'), isNull);
      expect(passwordProblem('ab12cd34'), isNull);
    });

    test('refuses short, letter-less and digit-less passwords', () {
      expect(passwordProblem('Ab1'), isNotNull);
      expect(passwordProblem('12345678'), isNotNull);
      expect(passwordProblem('abcdefgh'), isNotNull);
    });

    // bcrypt ignores anything past 72 bytes, so the server refuses longer.
    test('counts bytes, not characters, for the maximum', () {
      // A Latin letter and a digit, then Arabic: the server counts 2 bytes
      // for each Arabic letter, so this passes every rule but the length.
      final arabic = 'Ab1${'ب' * 40}';
      expect(utf8.encode(arabic).length, greaterThan(72));
      expect(arabic.length, lessThan(72));
      expect(passwordProblem(arabic), 'كلمة المرور طويلة جداً.');

      final ascii72 = 'a1${'b' * 70}';
      expect(utf8.encode(ascii72).length, 72);
      expect(passwordProblem(ascii72), isNull);
      expect(passwordProblem('${ascii72}c'), isNotNull);
    });

    test('every message is in Arabic', () {
      for (final bad in ['short1', '12345678', 'abcdefgh', 'a1${'b' * 80}']) {
        expect(passwordProblem(bad), matches(RegExp(r'[؀-ۿ]')));
      }
    });
  });

  group('email', () {
    test('matches the shape the server accepts', () {
      expect(isValidEmail('name@example.com'), isTrue);
      expect(isValidEmail('a.b+c@sub.example.co.uk'), isTrue);
    });

    test('refuses what the server refuses', () {
      for (final bad in [
        'name',
        'name@',
        '@example.com',
        'name@example',
        'name @example.com',
        'a@b.c d',
      ]) {
        expect(isValidEmail(bad), isFalse, reason: bad);
      }
    });
  });
}
