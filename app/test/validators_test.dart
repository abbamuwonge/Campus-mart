import 'package:flutter_test/flutter_test.dart';

import '../lib/utils/validators.dart';

void main() {
  group('email', () {
    test('accepts a normal address', () => expect(Validators.email('a@student.ug'), isNull));
    test('rejects a missing @', () => expect(Validators.email('student.ug'), isNotNull));
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
  });

  group('phone', () {
    test('accepts 07 format', () => expect(Validators.phone('0771234567'), isNull));
    test('accepts 256 format with spaces and +', () => expect(Validators.phone('+256 771 234 567'), isNull));
    test('rejects too short', () => expect(Validators.phone('07712345'), isNotNull));
    test('rejects letters', () => expect(Validators.phone('abcdefghij'), isNotNull));
  });

  group('password', () {
    test('accepts 8 characters', () => expect(Validators.newPassword('12345678'), isNull));
    test('rejects 7 characters', () => expect(Validators.newPassword('1234567'), isNotNull));
    test('rejects more than 72 characters', () => expect(Validators.newPassword('a' * 73), isNotNull));
    test('login only needs something typed', () {
      expect(Validators.requiredPassword(''), isNotNull);
      expect(Validators.requiredPassword('x'), isNull);
    });
  });

  group('names and campus', () {
    test('full name needs 2 characters', () {
      expect(Validators.fullName('A'), isNotNull);
      expect(Validators.fullName('Aslam'), isNull);
    });
    test('campus needs 2 characters', () {
      expect(Validators.campus(''), isNotNull);
      expect(Validators.campus('Makerere University'), isNull);
    });
  });

  test('confirm password must match', () {
    final check = Validators.sameAs(() => 'password123');
    expect(check('password123'), isNull);
    expect(check('different1'), isNotNull);
  });
}
