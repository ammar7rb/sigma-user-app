import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('private guest token persists independently from the public guest id', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = AuthRepository(
        dioClient: null, sharedPreferences: preferences);
    final service = AuthService(authRepoInterface: repository);

    await service.saveGuestId('42');
    expect(service.getGuestOrderToken(), isNull);
    await service.saveGuestOrderToken('42.1234567890.signature');
    final restored = AuthRepository(
        dioClient: null, sharedPreferences: preferences);
    expect(restored.getGuestIdToken(), '42');
    expect(restored.getGuestOrderToken(), '42.1234567890.signature');
    expect(restored.isLoggedIn(), isFalse);

    await service.saveGuestOrderToken(null);
    expect(service.getGuestOrderToken(), isNull);
    expect(service.getGuestIdToken(), '42');
    await service.saveGuestOrderToken('another-token');
    await service.clearGuestId();
    expect(service.getGuestOrderToken(), isNull);
    expect(service.isGuestIdExist(), isFalse);

    await service.saveGuestId('43');
    await service.saveGuestOrderToken('next-token');
    await service.clearSharedData();
    expect(service.getGuestOrderToken(), isNull);
    expect(service.isGuestIdExist(), isFalse);
  });
}
