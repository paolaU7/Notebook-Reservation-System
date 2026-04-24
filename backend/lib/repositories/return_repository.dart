// ignore_for_file: public_member_api_docs

import 'package:nrs_backend/database/connection.dart';
import 'package:nrs_backend/models/return_model.dart';
import 'package:ulid/ulid.dart';

class ReturnRepository {
  Future<ReturnModel?> findById(String id) async {
    final conn = await getConnection();
    final result = await conn.execute(
      r'''
        SELECT id, checkout_id, admin_id, device_notes, has_damage, returned_at
        FROM returns WHERE id = $1
      ''',
      parameters: [id],
    );
    if (result.isEmpty) return null;
    return ReturnModel.fromRow(result.first);
  }

  Future<ReturnModel?> findByCheckout(String checkoutId) async {
    final conn = await getConnection();
    final result = await conn.execute(
      r'''
        SELECT id, checkout_id, admin_id, device_notes, has_damage, returned_at
        FROM returns WHERE checkout_id = $1
      ''',
      parameters: [checkoutId],
    );
    if (result.isEmpty) return null;
    return ReturnModel.fromRow(result.first);
  }

  Future<bool> existsByCheckout(String checkoutId) async {
    return (await findByCheckout(checkoutId)) != null;
  }

  /// Crea la devolución y libera el dispositivo en una sola transacción.
  Future<ReturnModel> createWithTransaction({
    required String checkoutId,
    required String adminId,
    required String deviceId,
    required bool hasDamage,
    String? deviceNotes,
  }) async {
    final conn = await getConnection();
    final id   = Ulid().toString();

    await conn.runTx((tx) async {
      // 1. Crear la devolución
      await tx.execute(
        r'''
          INSERT INTO returns
            (id, checkout_id, admin_id, device_notes, has_damage)
          VALUES ($1, $2, $3, $4, $5)
        ''',
        parameters: [id, checkoutId, adminId, deviceNotes, hasDamage],
      );

      // 2. Device: in_use → available
      await tx.execute(
        r'UPDATE devices SET status = $1 WHERE id = $2',
        parameters: ['available', deviceId],
      );
    });

    return (await findById(id))!;
  }
}
