// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:nrs_backend/auth/auth_user.dart';
import 'package:nrs_backend/repositories/reservation_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _create(context),
    HttpMethod.get  => _getMyReservations(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _create(RequestContext context) async {
  final user = context.read<AuthUser>();
  final body = await context.request.json() as Map<String, dynamic>;

  final deviceId  = body['device_id']?.toString().trim();
  final date      = body['date']?.toString().trim();
  final startTime = body['start_time']?.toString().trim();
  final endTime   = body['end_time']?.toString().trim();

  if (deviceId  == null || deviceId.isEmpty  ||
      date      == null || date.isEmpty       ||
      startTime == null || startTime.isEmpty  ||
      endTime   == null || endTime.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'device_id, date, start_time y end_time son requeridos'},
    );
  }

  try {
    final repo = ReservationRepository();

    // Un estudiante solo puede tener una reserva por día
    if (await repo.studentHasReservationOnDate(
      studentId: user.userId,
      date:      date,
    )) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'Ya tenés una reserva para ese día'},
      );
    }

    // El dispositivo no puede estar reservado en ese horario
    if (await repo.hasConflict(
      deviceId:  deviceId,
      date:      date,
      startTime: startTime,
      endTime:   endTime,
    )) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'El dispositivo no está disponible en ese horario'},
      );
    }

    final reservation = await repo.createForStudent(
      studentId: user.userId,
      deviceId:  deviceId,
      date:      date,
      startTime: startTime,
      endTime:   endTime,
    );

    return Response.json(
      statusCode: HttpStatus.created,
      body: reservation.toJson(),
    );

  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Error interno: $e'},
    );
  }
}

Future<Response> _getMyReservations(RequestContext context) async {
  final user = context.read<AuthUser>();

  try {
    final reservations = await ReservationRepository()
        .getByStudent(user.userId);

    return Response.json(
      body: reservations.map((r) => r.toJson()).toList(),
    );

  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Error interno: $e'},
    );
  }
}
