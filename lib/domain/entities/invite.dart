class Invite {
  const Invite({
    required this.message,
    required this.imageId,
    required this.createdAt,
    this.inviteeName,
    this.letterTitle,
    this.letterBody,
    this.imageUrl,
    this.id,
  });

  final String? id;
  final String message;
  final String imageId;
  final String? imageUrl;
  final String? inviteeName;
  final String? letterTitle;
  final String? letterBody;
  final DateTime createdAt;

  Invite copyWith({
    String? id,
    String? message,
    String? imageId,
    String? imageUrl,
    String? inviteeName,
    String? letterTitle,
    String? letterBody,
    DateTime? createdAt,
  }) {
    return Invite(
      id: id ?? this.id,
      message: message ?? this.message,
      imageId: imageId ?? this.imageId,
      imageUrl: imageUrl ?? this.imageUrl,
      inviteeName: inviteeName ?? this.inviteeName,
      letterTitle: letterTitle ?? this.letterTitle,
      letterBody: letterBody ?? this.letterBody,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
