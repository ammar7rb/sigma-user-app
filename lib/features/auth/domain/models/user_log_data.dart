class UserLogData {
  String? countryCode;
  String? phoneNumber;
  String? email;

  UserLogData({this.countryCode, this.phoneNumber,this.email});

  UserLogData.fromJson(Map<String, dynamic> json) {
    countryCode = json['country_code'];
    phoneNumber = json['phone_number'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country_code'] = countryCode;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    return data;
  }
}
