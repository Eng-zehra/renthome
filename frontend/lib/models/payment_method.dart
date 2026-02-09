class PaymentMethod {
  final int id;
  final String cardType;
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardType,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      cardType: json['card_type'],
      cardHolder: json['card_holder'],
      cardNumber: json['card_number'],
      expiryDate: json['expiry_date'],
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_type': cardType,
      'card_holder': cardHolder,
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'is_default': isDefault,
    };
  }
}
