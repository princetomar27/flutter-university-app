class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  factory UserProfile.mock() {
    return UserProfile(
      name: 'John Doe',
      email: 'john.doe@example.com',
      avatarUrl: 'https://ui-avatars.com/api/?name=John+Doe&background=random',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'avatarUrl': avatarUrl};
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}
