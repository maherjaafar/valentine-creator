import 'package:flutter/material.dart';

import '../../domain/repositories/invite_repository.dart';
import '../../domain/usecases/create_invite.dart';
import '../../domain/usecases/get_invite_by_id.dart';

class AppScope extends InheritedWidget {
  AppScope({super.key, required InviteRepository repository, required super.child})
    : createInvite = CreateInviteUseCase(repository),
      getInviteById = GetInviteByIdUseCase(repository);

  final CreateInviteUseCase createInvite;
  final GetInviteByIdUseCase getInviteById;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return createInvite != oldWidget.createInvite || getInviteById != oldWidget.getInviteById;
  }
}
