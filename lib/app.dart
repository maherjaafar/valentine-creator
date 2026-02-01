import 'package:flutter/material.dart';

import 'core/di/app_scope.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'presentation/pages/create_invite_page.dart';
import 'presentation/pages/invite_page.dart';

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key, required this.bootstrap});

  final FirebaseBootstrapResult bootstrap;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      repository: bootstrap.repository,
      isFirebaseConfigured: bootstrap.isConfigured,
      child: MaterialApp(
        title: 'Valentine Invite',
        theme: AppTheme.light(),
        onGenerateRoute: (settings) {
          final name = settings.name ?? AppRoutes.create;
          if (name == AppRoutes.create) {
            return MaterialPageRoute(settings: settings, builder: (_) => const CreateInvitePage());
          }

          final uri = Uri.parse(name);
          if (AppRoutes.isInviteRoute(uri)) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => InvitePage(inviteId: uri.pathSegments[1]),
            );
          }

          return MaterialPageRoute(settings: settings, builder: (_) => const CreateInvitePage());
        },
      ),
    );
  }
}
