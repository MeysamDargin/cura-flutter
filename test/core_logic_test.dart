import 'package:cura/core/format/chat_timestamp.dart';
import 'package:cura/core/format/profile_name.dart';
import 'package:cura/core/validation/auth_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthInput.loginIssue', () {
    test('asks for both fields when either one is empty', () {
      expect(
        AuthInput.loginIssue(email: '', password: 'secret'),
        AuthInput.emptyLoginMessage,
      );
      expect(
        AuthInput.loginIssue(email: 'ada@cura.app', password: ' '),
        AuthInput.emptyLoginMessage,
      );
    });

    test('rejects a malformed email', () {
      expect(
        AuthInput.loginIssue(email: 'ada', password: 'secret'),
        AuthInput.invalidEmailMessage,
      );
    });

    test('accepts a complete login', () {
      expect(
        AuthInput.loginIssue(email: 'ada@cura.app', password: 'secret'),
        isNull,
      );
    });
  });

  group('AuthInput.registerIssue', () {
    test('requires every field', () {
      expect(
        AuthInput.registerIssue(
          fullName: 'Ada',
          email: 'ada@cura.app',
          password: 'secret',
          confirmPassword: '',
        ),
        AuthInput.emptyRegisterMessage,
      );
    });

    test('rejects a short password before comparing confirmation', () {
      expect(
        AuthInput.registerIssue(
          fullName: 'Ada Lovelace',
          email: 'ada@cura.app',
          password: '12345',
          confirmPassword: '12345',
        ),
        AuthInput.shortPasswordMessage,
      );
    });

    test('rejects a confirmation that does not match', () {
      expect(
        AuthInput.registerIssue(
          fullName: 'Ada Lovelace',
          email: 'ada@cura.app',
          password: 'secret',
          confirmPassword: 'Secret',
        ),
        AuthInput.passwordMismatchMessage,
      );
    });

    test('accepts a complete registration', () {
      expect(
        AuthInput.registerIssue(
          fullName: 'Ada Lovelace',
          email: 'ada@cura.app',
          password: 'secret',
          confirmPassword: 'secret',
        ),
        isNull,
      );
    });
  });

  group('profile names', () {
    test('uses the first word and a fallback', () {
      expect(displayFirstName('Ada Lovelace'), 'Ada');
      expect(displayFirstName('  '), defaultProfileName);
      expect(displayFirstName(null), defaultProfileName);
    });

    test('uses the first letter in uppercase', () {
      expect(displayInitial('ada'), 'A');
      expect(displayInitial(null), defaultProfileInitial);
    });
  });

  group('formatChatTimestamp', () {
    final now = DateTime(2026, 10, 6, 18);

    test('returns an empty string when there is no time', () {
      expect(formatChatTimestamp(null, now: now), '');
    });

    test('shows the clock time for a message from today', () {
      expect(
        formatChatTimestamp(DateTime(2026, 10, 6, 9, 5), now: now),
        '09:05',
      );
    });

    test('shows the day and month for an older message', () {
      expect(
        formatChatTimestamp(DateTime(2026, 10, 5, 9, 5), now: now),
        '05/10',
      );
    });
  });
}
