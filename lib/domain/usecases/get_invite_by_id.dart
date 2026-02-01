import '../entities/invite.dart';
import '../repositories/invite_repository.dart';

class GetInviteByIdUseCase {
  const GetInviteByIdUseCase(this._repository);

  final InviteRepository _repository;

  Future<Invite?> call(String id) {
    return _repository.getInviteById(id);
  }
}
