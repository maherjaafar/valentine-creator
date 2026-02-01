class Invite {
  const Invite({
    required this.message,
    required this.imageId,
    required this.createdAt,
    this.imageUrl,
    this.id,
  });

  final String? id;
  final String message;
  final String imageId;
  final String? imageUrl;
  final DateTime createdAt;

  Invite copyWith({
    String? id,
    String? message,
    String? imageId,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Invite(
      id: id ?? this.id,
      message: message ?? this.message,
      imageId: imageId ?? this.imageId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
