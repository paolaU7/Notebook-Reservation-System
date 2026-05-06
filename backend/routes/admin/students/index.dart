// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:nrs_backend/database/connection.dart';
import 'package:nrs_backend/middleware/admin_auth.dart';
import 'package:nrs_backend/models/student.dart';

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
    final conn = await getConnection();

    // Traer todos los alumnos con info de watchlist via LEFT JOIN
    final result = await conn.execute('''
      SELECT
        s.id, s.full_name, s.email, s.dni,
        s.year, s.division, s.is_active, s.created_at, s.specialty,
        COALESCE(w.damage_count, 0) AS damage_count,
        COALESCE(w.active, true)    AS watchlist_active
      FROM students s
      LEFT JOIN watchlist w ON w.dni = s.dni
      ORDER BY s.full_name ASC
    ''');

    final students = result.map((row) {
      final student = Student.fromRow(row.sublist(0, 9));
      return {
        ...student.toJson(),
        'damage_count':     row[9]! as int,
        'watchlist_active': row[10]! as bool,
      };
    }).toList();

    return Response.json(body: students);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Error interno: $e'},
    );
  }
}