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
  });

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
      );

  /// A friendly label for the ID proof, e.g. "PAN · ABCDE1234F".
  String get idLabel {
    if (idNumber.isEmpty) return 'Not provided';
    final t = idType == 'pan' ? 'PAN' : idType == 'aadhaar' ? 'Aadhaar' : 'GST';
    return '$t · $idNumber';
  }
}
