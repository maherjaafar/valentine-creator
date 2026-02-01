import 'package:flutter/foundation.dart';

import '../routing/app_routes.dart';

class LinkBuilder {
  static String inviteLink(String id) {
    if (kIsWeb) {
      return '${Uri.base.origin}${AppRoutes.invite(id)}';
    }
    return AppRoutes.invite(id);
  }
}
