import 'dart:math';

import '../../domain/entities/invite.dart';
import '../../domain/repositories/invite_repository.dart';

class InMemoryInviteRepository implements InviteRepository {
  final Map<String, Invite> _storage = {};
  final Random _random = Random();

  @override
  Future<String> createInvite(Invite invite) async {
    final id = _generateId();
    _storage[id] = invite.copyWith(id: id);
    return id;
  }

  @override
  Future<Invite?> getInviteById(String id) async {
    return _storage[id];
  }

  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}
