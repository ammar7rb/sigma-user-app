class AccountOverviewModel {
  final double purchaseBalance;
  final double insuranceAvailableBalance;
  final double insuranceHeldBalance;
  final int pendingInvoicesCount;
  final bool purchaseEnabled;
  final bool insuranceEnabled;
  final bool taxEnabled;

  const AccountOverviewModel({
    required this.purchaseBalance,
    required this.insuranceAvailableBalance,
    required this.insuranceHeldBalance,
    required this.pendingInvoicesCount,
    required this.purchaseEnabled,
    required this.insuranceEnabled,
    required this.taxEnabled,
  });

  factory AccountOverviewModel.fromJson(Map<String, dynamic> json) {
    final insurance = json['insurance'] is Map
        ? Map<String, dynamic>.from(json['insurance'] as Map)
        : const <String, dynamic>{};
    return AccountOverviewModel(
      purchaseBalance: _number(json['purchase_balance']),
      insuranceAvailableBalance: _number(insurance['available_balance']),
      insuranceHeldBalance: _number(insurance['held_balance']),
      pendingInvoicesCount:
          int.tryParse('${json['pending_invoices_count'] ?? 0}') ?? 0,
      purchaseEnabled:
          json['purchase_enabled'] == true || json['purchase_enabled'] == 1,
      insuranceEnabled:
          json['insurance_enabled'] == true || json['insurance_enabled'] == 1,
      taxEnabled: json['tax_enabled'] == true || json['tax_enabled'] == 1,
    );
  }

  static double _number(dynamic value) => double.tryParse('$value') ?? 0;
}
