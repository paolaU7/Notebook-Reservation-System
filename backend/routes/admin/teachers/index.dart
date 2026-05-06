// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:nrs_backend/middleware/admin_auth.dart';
import 'package:nrs_backend/repositories/teacher_repository.dart';

Handler middleware(Handler handler) {
  return adminAuthMiddleware(handler);
}

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getAll(),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getAll() async {
  try {
    final teachers = await TeacherRepository().getAll();
    return Response.json(
      body: teachers.map((t) => t.toJson()).toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Error interno: $e'},
    );
  }
}