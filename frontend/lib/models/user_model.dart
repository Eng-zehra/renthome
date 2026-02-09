class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
    };
  }
}
