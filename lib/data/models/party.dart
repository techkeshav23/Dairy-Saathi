class Party {
  final String id;
  final String name;
  final String phone;
  final String type;
  final String address;
  final String gstin;
  final double openingBalance;
  final double balance;

  const Party({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.address = '',
    this.gstin = '',
    this.openingBalance = 0.0,
    this.balance = 0.0,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      type: json['type'] as String,
      address: json['address'] as String? ?? '',
      gstin: json['gstin'] as String? ?? '',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'type': type,
      'address': address,
      'gstin': gstin,
      'openingBalance': openingBalance,
      'balance': balance,
    };
  }

  Party copyWith({
    String? id,
    String? name,
    String? phone,
    String? type,
    String? address,
    String? gstin,
    double? openingBalance,
    double? balance,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      openingBalance: openingBalance ?? this.openingBalance,
      balance: balance ?? this.balance,
    );
  }
}