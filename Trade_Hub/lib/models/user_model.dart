class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? companyName;
  final String? role; // e.g., "Supplier", "Distributor", "Business Owner"
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.companyName,
    this.role,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      companyName: json['companyName'] as String?,
      role: json['role'] as String?,
      location: json['location'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'companyName': companyName,
      'role': role,
      'location': location,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Get avatar URL with fallback to default person icon
  String getAvatarUrl() {
    // Return the user's avatar if available
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return avatarUrl!;
    }

    // Default person icon URL - using a reliable placeholder service
    // This ensures we always have a fallback when avatarUrl is null or empty
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';
  }

  // Check if user has a custom avatar
  bool hasCustomAvatar() {
    return avatarUrl != null && avatarUrl!.isNotEmpty;
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? companyName,
    String? role,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      companyName: companyName ?? this.companyName,
      role: role ?? this.role,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}