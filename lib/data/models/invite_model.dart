import '../../domain/entities/invite.dart';

class InviteModel {
  const InviteModel({
    required this.message,
    required this.imageId,
    required this.createdAt,
    this.imageUrl,
  });

  final String message;
  final String imageId;
  final String? imageUrl;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'imageId': imageId,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static InviteModel fromMap(Map<String, dynamic> map) {
    return InviteModel(
      message: map['message'] as String? ?? '',
      imageId: map['imageId'] as String? ?? 'heart',
      imageUrl: map['imageUrl'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Invite toEntity(String id) {
    return Invite(
      id: id,
      message: message,
      imageId: imageId,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }

  static InviteModel fromEntity(Invite invite) {
    return InviteModel(
      message: invite.message,
      imageId: invite.imageId,
      imageUrl: invite.imageUrl,
      createdAt: invite.createdAt,
    );
  }
}
