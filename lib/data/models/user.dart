/// The signed-in retailer (the shop buying wholesale).
class UserModel {
  final String name;
  final String shopName;
  final String phone;
  final String email;
  final String address;
  final String area;
  final String gstin;
  final String idType;   // 'gst' | 'pan' | 'aadhaar'
  final String idNumber;
  final String code;     // short sequential retailer code (e.g. "1")
  final String accountType; // 'retailer' | 'firm'

  const UserModel({
    required this.name,
    required this.shopName,
    required this.phone,
    this.email = '',
    this.address = '',
    this.area = '',
    this.gstin = '',
    this.idType = 'gst',
    this.idNumber = '',
    this.code = '',
    this.accountType = 'retailer',
  });

  bool get isFirm => accountType == 'firm';

  /// Display label for the buyer type — "Firm" or "Retailer".
  String get typeLabel => isFirm ? 'Firm' : 'Retailer';

  /// Label for the business name field/heading — "Firm" vs "Shop".
  String get businessLabel => isFirm ? 'Firm' : 'Shop';

  UserModel copyWith({
    String? name,
    String? shopName,
    String? phone,
    String? email,
    String? address,
    String? area,
    String? gstin,
    String? idType,
    String? idNumber,
    String? code,
    String? accountType,
  }) =>
      UserModel(
        name: name ?? this.name,
        shopName: shopName ?? this.shopName,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        area: area ?? this.area,
        gstin: gstin ?? this.gstin,
        idType: idType ?? this.idType,
        idNumber: idNumber ?? this.idNumber,
        code: code ?? this.code,
        accountType: accountType ?? this.accountType,
      );

  /// A friendly label for the ID proof, e.g. "PAN · ABCDE1234F".
  String get idLabel {
    if (idNumber.isEmpty) return 'Not provided';
    final t = idType == 'pan' ? 'PAN' : idType == 'aadhaar' ? 'Aadhaar' : 'GST';
    return '$t · $idNumber';
  }
}
