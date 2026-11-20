import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('existing-id splash branches route directly and no-id branches await guests', () {
    final source = File('lib/features/splash/screens/splash_screen.dart')
        .readAsStringSync();
    final branches = RegExp(
      r"\.getGuestToken\(\) !=\s*'1'\) \{\s*"
      r'([\s\S]*?)RouterHelper\.getDashboardRoute\(\s*'
      r'action: RouteAction\.(\w+),\s*\);\s*'
      r'\} else \{\s*await Provider\.of<AuthController>\(\s*'
      r'Get\.context!,\s*listen: false,\s*\)\.getGuestIdUrl\(\);\s*'
      r'RouterHelper\.getDashboardRoute\(\s*'
      r'action: RouteAction\.(\w+),\s*\);',
    ).allMatches(source);
    expect(branches.map((match) => match.group(2)),
        ['pushReplacement', 'pushReplacement']);
    for (final branch in branches) {
      expect(branch.group(1), isNot(contains('getGuestIdUrl')));
    }
    expect(branches.map((match) => match.group(3)),
        ['pushReplacement', 'pushNamedAndRemoveUntil']);
    expect(source, isNot(contains('ensureGuestOrderToken')));
    expect(source, isNot(contains('guest_order_token_helper')));
    expect(RegExp(r'\.getGuestIdUrl\(\)').allMatches(source), hasLength(2));
  });

  final awaitSites = <String, String>{
    'lib/features/onboarding/screens/onboarding_screen.dart':
        'pushNamedAndRemoveUntil',
    'lib/features/auth/screens/login_screen.dart': 'pushReplacement',
    'lib/features/auth/screens/otp_login_screen.dart':
        'pushNamedAndRemoveUntil',
    'lib/features/auth/widgets/only_social_login_widget.dart':
        'pushNamedAndRemoveUntil',
  };
  for (final site in awaitSites.entries) {
    test('${site.key} awaits guest creation before its unchanged route', () {
      final source = File(site.key).readAsStringSync();
      expect(RegExp(r'\.getGuestIdUrl\(\)').allMatches(source), hasLength(1));
      final route = RegExp(
        r'await (?:authProvider|Provider\.of<AuthController>\('
        r'context, listen: false\))\.getGuestIdUrl\(\);\s*'
        r'RouterHelper\s*\.getDashboardRoute\(\s*'
        r"(?:page: 'home',\s*)?action: RouteAction\s*\.(\w+)",
      ).firstMatch(source);
      expect(route, isNotNull);
      expect(route?.group(1), site.value);
      expect(
        source,
        contains(site.key.contains('onboarding')
            ? 'Future<void> _finish(BuildContext context) async {'
            : 'onTap: () async {'),
      );
    });
  }
}
