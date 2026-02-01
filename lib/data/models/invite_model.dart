import '../../domain/entities/invite.dart';

class InviteModel {
  const InviteModel({
    required this.message,
    required this.imageId,
    required this.createdAt,
    this.imageUrl,
    this.inviteeName,
    this.letterTitle,
    this.letterBody,
  });

  final String message;
  final String imageId;
  final String? imageUrl;
  final String? inviteeName;
  final String? letterTitle;
  final String? letterBody;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'imageId': imageId,
      'imageUrl': imageUrl,
      'inviteeName': inviteeName,
      'letterTitle': letterTitle,
      'letterBody': letterBody,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static InviteModel fromMap(Map<String, dynamic> map) {
    return InviteModel(
      message: map['message'] as String? ?? '',
      imageId: map['imageId'] as String? ?? 'heart',
      imageUrl: map['imageUrl'] as String?,
      inviteeName: map['inviteeName'] as String?,
      letterTitle: map['letterTitle'] as String?,
      letterBody: map['letterBody'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Invite toEntity(String id) {
    return Invite(
      id: id,
      message: message,
      imageId: imageId,
      imageUrl: imageUrl,
      inviteeName: inviteeName,
      letterTitle: letterTitle,
      letterBody: letterBody,
      createdAt: createdAt,
    );
  }

  static InviteModel fromEntity(Invite invite) {
    return InviteModel(
      message: invite.message,
      imageId: invite.imageId,
      imageUrl: invite.imageUrl,
      inviteeName: invite.inviteeName,
      letterTitle: invite.letterTitle,
      letterBody: invite.letterBody,
      createdAt: invite.createdAt,
    );
  }
}
