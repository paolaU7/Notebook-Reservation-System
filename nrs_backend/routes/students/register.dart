import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:nrs_backend/repositories/student_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final repo = StudentRepository();

    final year = body['year'] as int;
    final division = body['division'] as int;

    if (year < 1 || year > 7) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'A�o inv�lido'},
      );
    }

    if (division < 1 || division > 10) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Divisi�n inv�lida'},
      );
    }

    if (await repo.existsByEmail(body['email'] as String)) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'Email ya registrado'},
      );
    }

    if (await repo.existsByDni(body['dni'] as String)) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'DNI ya registrado'},
      );
    }

    final student = await repo.register(
      fullName: body['full_name'] as String,
      email:    body['email']    as String,
      dni:      body['dni']      as String,
      year:     year,
      division: division,
    );

    if (student == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'No se pudo registrar el estudiante'},
      );
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: student.toJson(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Error interno: $e'},
    );
  }
}
