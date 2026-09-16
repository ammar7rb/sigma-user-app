import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/models/order_insurance_quote_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/domain/models/profile_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/domain/models/customer_order_insurance_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/domain/models/wallet_transaction_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/egypt_location_helper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

void main() {
  test('Arabic includes every English translation key', () {
    final english =
        jsonDecode(File('assets/language/en.json').readAsStringSync()) as Map;
    final arabic =
        jsonDecode(File('assets/language/ar.json').readAsStringSync()) as Map;
    expect(
        english.keys.where((key) =>
            !arabic.containsKey(key) || '${arabic[key]}'.trim().isEmpty),
        isEmpty);
  });

  test('production dashboard uses the live redesigned customer surfaces', () {
    final dashboard =
        File('lib/features/dashboard/screens/dashboard_screen.dart')
            .readAsStringSync();
    final more = File('lib/features/more/screens/more_screen_view.dart')
        .readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(dashboard, contains('const HomePage()'));
    expect(dashboard,
        contains('screen: const CategoryScreen(fromDashboard: true)'));
    expect(dashboard, contains("name: 'CATEGORY'"));
    expect(dashboard, contains('screen: const MoreScreen()'));
    expect(dashboard, contains("name: 'profile'"));
    expect(dashboard, isNot(contains("name: 'orders'")));
    expect(dashboard, isNot(contains('ProfileDashboardPreview')));
    expect(more, contains('ProfileInfoSectionWidget'));
    expect(more, contains('CustomerWalletScreen'));
    expect(more, contains('PendingPostPurchaseInvoicesScreen'));
    expect(more, contains('RouterHelper.getOrderScreenRoute'));
    expect(mainSource, contains('if (!kIsWeb)'));
  });

  test(
      'customer polish keeps cart, activation, guest profile and onboarding consistent',
      () {
    final cartWidget =
        File('lib/features/cart/widgets/cart_widget.dart').readAsStringSync();
    final profile =
        File('lib/features/more/widgets/profile_info_section_widget.dart')
            .readAsStringSync();
    final support =
        File('lib/features/support/screens/support_conversation_screen.dart')
            .readAsStringSync();
    final images = File('lib/utill/images.dart').readAsStringSync();

    expect(cartWidget, isNot(contains('CustomCheckbox')));
    expect(profile, contains('if (isGuestMode) ...['));
    expect(support, contains("rawSubject == 'customer_account_activation'"));
    expect(support, contains('Icons.add_photo_alternate_outlined'));
    expect(images, contains('onboarding_secure_payment.png'));
    expect(images, contains('onboarding_medical_delivery.png'));
    expect(File('assets/images/onboarding_secure_payment.png').existsSync(),
        isTrue);
    expect(File('assets/images/onboarding_medical_delivery.png').existsSync(),
        isTrue);
  });

  test('checkout exposes only the three approved prepaid choices', () {
    final paymentSheet = File(
            'lib/features/checkout/widgets/payment_method_bottom_sheet_widget.dart')
        .readAsStringSync();
    final preview =
        File('lib/features/dashboard/screens/customer_polish_preview.dart')
            .readAsStringSync();

    expect(paymentSheet, contains('selectPurchaseWallet'));
    expect(paymentSheet, contains("_channelIndex(methods, 'wallet')"));
    expect(paymentSheet, contains("_channelIndex(methods, 'instapay')"));
    expect(paymentSheet, contains('return index;'));
    expect(paymentSheet, isNot(contains('methods.length > 1 ? 1 : 0')));
    expect(preview, contains('رصيد المشتريات'));
    expect(preview, contains('محفظة إلكترونية'));
    expect(preview, contains('إنستا باي'));
    expect(preview,
        isNot(contains('ستختار عنوان وطريقة الشحن في الخطوة التالية')));
  });

  test('production purchase journey uses real routed screens, not previews',
      () {
    final routes = File('lib/helper/route_healper.dart').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final checkout = File('lib/features/checkout/screens/checkout_screen.dart')
        .readAsStringSync();
    final transfer =
        File('lib/features/offline_payment/screens/offline_payment_screen.dart')
            .readAsStringSync();
    final insurance = File(
            'lib/features/order_insurance/screens/customer_order_insurance_screen.dart')
        .readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(mainSource,
        contains("if (const bool.fromEnvironment('SCREENSHOT_MODE'))"));
    expect(routes, contains('return CartScreen('));
    expect(routes, contains('return CheckoutScreen('));
    expect(routes, contains('return OfflinePaymentScreen('));
    expect(routes, contains('CustomerOrderInsuranceScreen('));
    expect(routes, contains('return AddNewAddressScreen('));
    expect(routes, isNot(contains('CustomerPolishPreview')));
    expect(checkout, isNot(contains('toggleTermsCheck(isUpdate: false)')));
    expect(transfer, contains('senderNameController'));
    expect(transfer, contains('senderIdentifierController'));
    expect(transfer, contains('_pickedImage'));
    expect(insurance, contains('إيداع رصيد التأمين'));
    expect(pubspec, contains('family: Cairo'));
  });

  test('delivery address and shipping prices use the live governorate API', () {
    final address =
        File('lib/features/address/screens/add_new_address_screen.dart')
            .readAsStringSync();
    final constants = File('lib/utill/app_constants.dart').readAsStringSync();
    final shipping =
        File('lib/features/shipping/controllers/shipping_controller.dart')
            .readAsStringSync();

    expect(address, contains('_mapAddressPickerEnabled = false'));
    expect(address, contains('addressController.shippingGovernorates'));
    expect(address, contains('latitude: null'));
    expect(address, contains('longitude: null'));
    expect(constants, contains('/api/v1/mapapi/shipping-governorates'));
    expect(shipping, contains('quoteForAddress'));
    expect(shipping, contains('selectQuoteForAddress'));
  });

  test('first payment preserves server total without adding second stage tax',
      () {
    final quote = OrderInsuranceQuoteModel.fromJson({
      'post_purchase_enabled': true,
      'first_payment_amount': '110.50',
      'total': '40',
    });
    expect(quote.postPurchaseEnabled, isTrue);
    expect(quote.firstPaymentAmount, 110.50);
    expect(quote.total, 40);
  });
  test('mobile environment and Egypt-only location contract are valid', () {
    expect(AppConstants.baseUrl, isNotEmpty);
    expect(
        EgyptLocationHelper.contains(const LatLng(30.0444, 31.2357)), isTrue);
    expect(
        EgyptLocationHelper.contains(const LatLng(25.2048, 55.2708)), isFalse);
  });

  test('profile parses customer activation support state', () {
    final profile = ProfileModel.fromJson({
      'id': 10,
      'wallet_balance': 0,
      'loyalty_point': 0,
      'activation': {
        'customer_reference': 'C10',
        'status': 'activation_ticket_open',
        'is_active': false,
        'ticket_id': 7,
      },
    });

    expect(profile.activation?.customerReference, 'C10');
    expect(profile.activation?.isActive, isFalse);
    expect(profile.activation?.ticketId, 7);
  });

  test('insurance quote and shipping confirmation fields use API snapshots',
      () {
    final quote = OrderInsuranceQuoteModel.fromJson({
      'applicable': true,
      'total': '50',
      'original_total': '60',
      'discount_total': '10',
      'maturity_days': 90,
      'withdrawable': false,
      'balance': {'available_balance': '25'},
    });
    final order = Orders.fromJson({
      'id': 44,
      'order_amount': 1000,
      'discount_amount': 0,
      'shipping_cost': 50,
      'extra_discount': 0,
      'shipment_reference': 'SHP-44',
      'customer_delivery_confirmation_status': 'pending',
    });

    expect(quote.total, 50);
    expect(quote.withdrawable, isFalse);
    expect(order.shipmentReference, 'SHP-44');
    expect(order.customerDeliveryConfirmationStatus, 'pending');
    expect(AppConstants.confirmOrderReceiptUri, contains('confirm-receipt'));
  });

  test(
      'post-purchase insurance contract keeps purchase and insurance wallets separate',
      () {
    final envelope = CustomerOrderInsuranceEnvelope.fromJson({
      'claim': {
        'contract_version': '2.0',
        'flow_status': 'customer_insurance_pending',
        'order_reference': 'ORD-44',
        'purchase_amount': '1000',
        'insurance': {
          'amount': '75',
          'payment_status': 'unpaid',
          'status': 'pending_payment',
          'balance_use_policy': 'insurance_only',
        },
        'order_is_suspended_until_insurance_payment': true,
        'support_available': true,
        'purchase_refund': {'status': 'not_requested'},
      },
      'insurance_balance': {
        'available_balance': '50',
        'held_balance': '25',
        'withdrawable': false,
        'allowed_uses': ['insurance_payment'],
      },
      'payment_options': {
        'insurance_balance': true,
        'digital_payment': true,
        'offline_payment': true,
        'gateways': [
          {'key': 'paymob', 'title': 'Paymob'}
        ],
        'offline_methods': [
          {'id': 2, 'method_name': 'Bank'}
        ],
      },
    });
    final wallet = WalletTransactionModel.fromJson({
      'limit': 10,
      'offset': 1,
      'total_size': 0,
      'total_wallet_balance': '300',
      'insurance_available_balance': '50',
      'insurance_held_balance': '25',
      'insurance_ledger_entries': [
        {
          'id': 1,
          'order_id': 44,
          'entry_type': 'hold',
          'credit': 0,
          'debit': 75
        },
      ],
      'wallet_transaction_list': [],
    });

    expect(envelope.claim.canPay, isTrue);
    expect(envelope.claim.suspended, isTrue);
    expect(envelope.claim.balanceUsePolicy, 'insurance_only');
    expect(envelope.balance.allowedUses, ['insurance_payment']);
    expect(wallet.totalWalletBalance, 300);
    expect(wallet.insuranceAvailableBalance, 50);
    expect(wallet.insuranceLedgerEntries?.single.orderId, 44);
  });
}
