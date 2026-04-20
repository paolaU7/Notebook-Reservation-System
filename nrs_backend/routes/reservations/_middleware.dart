// ignore_for_file: public_member_api_docs

import 'package:dart_frog/dart_frog.dart';
import 'package:nrs_backend/middleware/auth_middleware.dart';
import 'package:nrs_backend/middleware/role_middleware.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final method = context.request.method;
    final path   = context.request.uri.path;

    // GET /reservations/all → solo admin
    if (path.endsWith('/all') && method == HttpMethod.get) {
      final roled  = requireRoles(handler, ['admin']);
      final authed = authMiddleware(roled);
      return authed(context);
    }

    // POST /reservations → solo student
    // GET /reservations → student ve las suyas
    final roled  = requireRoles(handler, ['student', 'admin']);
    final authed = authMiddleware(roled);
    return authed(context);
  };
}
