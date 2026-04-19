// ignore_for_file: public_member_api_docs

import 'package:dart_frog/dart_frog.dart';
import 'package:nrs_backend/middleware/admin_auth.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // El login no requiere auth de admin
    final path = context.request.uri.path;
    if (path.endsWith('/login')) return handler(context);

    return adminAuthMiddleware(handler)(context);
  };
}
