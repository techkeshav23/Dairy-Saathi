/// The signed-in retailer (the shop buying wholesale).
class UserModel {
  final String name;
  final String shopName;
  final String phone;
  final String address;
  final String gstin;

  const UserModel({
    required this.name,
    required this.shopName,
    required this.phone,
    this.address = '',
    this.gstin = '',
  });

  UserModel copyWith({
    String? name,
    String? shopName,
    String? phone,
    String? address,
    String? gstin,
  }) =>
      UserModel(
        name: name ?? this.name,
        shopName: shopName ?? this.shopName,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        gstin: gstin ?? this.gstin,
      );
}
