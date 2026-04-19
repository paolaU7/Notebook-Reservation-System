// ignore_for_file: public_member_api_docs

import 'package:dart_frog/dart_frog.dart';
import 'package:nrs_backend/middleware/auth_middleware.dart';
import 'package:nrs_backend/middleware/role_middleware.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final path = context.request.uri.path;
    if (path.endsWith('/login')) return handler(context);

    // Primero roles (más interno), después auth (más externo)
    // El request entra por auth → inyecta AuthUser → llega a roles → lo lee
    final roled  = requireRoles(handler, ['admin']);
    final authed = authMiddleware(roled);
    return authed(context);
  };
}
