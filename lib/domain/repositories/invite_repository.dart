import '../entities/invite.dart';

abstract class InviteRepository {
  Future<String> createInvite(Invite invite);
  Future<Invite?> getInviteById(String id);
}
