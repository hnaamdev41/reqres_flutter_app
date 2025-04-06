class User {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;

  User({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle potential type conversions
    int? id;
    if (json['id'] != null) {
      id = json['id'] is String ? int.tryParse(json['id']) : json['id'] as int;
    }
    
    return User(
      id: id,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      if (id != null) 'id': id,
      if (avatar != null) 'avatar': avatar,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
    );
  }
}