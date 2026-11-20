import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';

/// Reports token availability without replacing an existing guest identity.
Future<bool> ensureGuestOrderToken(AuthController auth) async {
  // The API creates a new guest rather than issuing a token for an existing id.
  // Only the splash no-id branches may create a guest; never recover one here.
  return auth.getGuestOrderToken()?.isNotEmpty == true;
}
