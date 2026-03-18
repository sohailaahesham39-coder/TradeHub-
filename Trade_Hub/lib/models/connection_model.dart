import 'user_model.dart';

class Connection {
  final String id;
  final String userId1;
  final String userId2;
  final User? user1; // Optional full User object
  final User? user2;
  final String status; // e.g., "pending", "accepted", "rejected"
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Connection({
    required this.id,
    required this.userId1,
    required this.userId2,
    this.user1,
    this.user2,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String,
      userId1: json['userId1'] as String,
      userId2: json['userId2'] as String,
      user1: json['user1'] != null ? User.fromJson(json['user1'] as Map<String, dynamic>) : null,
      user2: json['user2'] != null ? User.fromJson(json['user2'] as Map<String, dynamic>) : null,
      status: json['status'] as String,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'user1': user1?.toJson(),
      'user2': user2?.toJson(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Connection copyWith({
    String? id,
    String? userId1,
    String? userId2,
    User? user1,
    User? user2,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Connection(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}