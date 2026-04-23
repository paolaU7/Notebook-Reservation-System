// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:nrs_backend/auth/auth_user.dart';
import 'package:nrs_backend/repositories/checkout_repository.dart';
import 'package:nrs_backend/repositories/device_repository.dart';
import 'package:nrs_backend/repositories/reservation_repository.dart';
import 'package:nrs_backend/repositories/student_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final user          = context.read<AuthUser>();
  final body          = await context.request.json() as Map<String, dynamic>;
  final reservationId = body['reservation_id']?.toString().trim();
  final deviceNotes   = body['device_notes']?.toString().trim();
  final confirm       = body['confirm'] == true;

  if (reservationId == null || reservationId.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'reservation_id es requerido'},
    );
  }

  try {
    final reservationRepo = ReservationRepository();
    final reservation     = await reservationRepo.findById(reservationId);

    if (reservation == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Reserva no encontrada'},
      );
    }

    if (reservation.status != 'pending' &&
        reservation.status != 'confirmed') {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'error': 'No se puede hacer checkout de una reserva '
              'con estado: ${reservation.status}',
        },
      );
    }

    if (await reservationRepo.hasActiveCheckout(reservationId)) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'Esta reserva ya tiene un checkout registrado'},
      );
    }

    final device = await DeviceRepository().findById(reservation.deviceId);
    if (device == null || device.status != 'available') {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'El dispositivo no está disponible para retiro'},
      );
    }

    // ── Reserva de alumno ────────────────────────────────────────────────────
    if (reservation.bookerType == 'student') {
      final studentRepo = StudentRepository();
      final student     = await studentRepo.findById(reservation.studentId!);
      final wasInactive = student != null && !student.isActive;

      // Alumno inactivo y admin no confirmó → devolver warning
      if (wasInactive && !confirm) {
        return Response.json(
          statusCode: HttpStatus.accepted, // 202
          body: {
            'requires_confirmation': true,
            'message':
                'El alumno no está activado. '
                'Verificá sus datos antes de continuar. '
                'Al aprobar, la cuenta se activará automáticamente.',
            'student': {
              'id':        student.id,
              'full_name': student.fullName,
              'dni':       student.dni,
              'email':     student.email,
            },
          },
        );
      }

      // Proceder con el checkout
      final checkout = await CheckoutRepository().create(
        reservationId: reservationId,
        adminId:       user.userId,
        deviceNotes:   deviceNotes,
      );

      await DeviceRepository().updateStatus(reservation.deviceId, 'in_use');
      await reservationRepo.updateStatus(reservationId, 'completed');

      // Activar alumno si era su primer retiro
      if (wasInactive) {
        await studentRepo.activate(student.id);
      }

      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'checkout':          checkout.toJson(),
          'student_activated': wasInactive,
        },
      );
    }

    // ── Reserva de profesor → checkout directo, sin warning ─────────────────
    final checkout = await CheckoutRepository().create(
      reservationId: reservationId,
      adminId:       user.userId,
      deviceNotes:   deviceNotes,
    );

    await DeviceRepository().updateStatus(reservation.deviceId, 'in_use');
    await reservationRepo.updateStatus(reservationId, 'completed');

    return Response.json(
      statusCode: HttpStatus.created,
      body: checkout.toJson(),
    );

  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Error interno: $e'},
    );
  }
}
