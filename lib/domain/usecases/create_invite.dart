import '../entities/invite.dart';
import '../repositories/invite_repository.dart';

class CreateInviteUseCase {
  const CreateInviteUseCase(this._repository);

  final InviteRepository _repository;

  Future<String> call(Invite invite) {
    return _repository.createInvite(invite);
  }
}
