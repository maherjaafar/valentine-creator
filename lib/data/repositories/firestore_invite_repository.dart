import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/invite.dart';
import '../../domain/repositories/invite_repository.dart';
import '../models/invite_model.dart';

class FirestoreInviteRepository implements InviteRepository {
  FirestoreInviteRepository(FirebaseFirestore firestore)
    : _collection = firestore.collection('valentine_invites');

  final CollectionReference<Map<String, dynamic>> _collection;

  @override
  Future<String> createInvite(Invite invite) async {
    final model = InviteModel.fromEntity(invite);
    final doc = _collection.doc();
    await doc.set(model.toMap());
    return doc.id;
  }

  @override
  Future<Invite?> getInviteById(String id) async {
    final snapshot = await _collection.doc(id).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    return InviteModel.fromMap(data).toEntity(snapshot.id);
  }
}
