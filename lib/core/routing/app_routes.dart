class AppRoutes {
  static const String create = '/';

  static String invite(String id) => '/invite/$id';

  static bool isInviteRoute(Uri uri) {
    return uri.pathSegments.length == 2 && uri.pathSegments.first == 'invite';
  }
}
