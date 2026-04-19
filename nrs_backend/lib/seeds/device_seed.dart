// ignore_for_file: public_member_api_docs

import 'package:nrs_backend/database/connection.dart';

Future<void> seedDevices() async {
  final conn = await getConnection();

  final now = DateTime.now().toUtc();


  final devices = <Map<String, dynamic>>[];
  for (var i = 1; i <= 24; i++) {
    final paddedNumber = i.toString().padLeft(3, '0');
    devices.add({
      'id': 'NB-CI-$paddedNumber',
      'name': 'Conectar Igualdad Notebook #$paddedNumber',
      'serial_number': 'CI-NB-$paddedNumber',
      'type': 'notebook',
      'status': i <= 22 ? 'active' : 'maintenance',
      'created_at': now,
      'updated_at': now,
    });
  }

  // Add 2 TVs
  devices.addAll([
    {
      'id': 'TV001',
      'name': 'LG OLED Smart TV 65"',
      'serial_number': 'SN-LG-TV-001',
      'type': 'tv',
      'status': 'active',
      'created_at': now,
      'updated_at': now,
    },
    {
      'id': 'TV002',
      'name': 'Samsung 4K Smart TV 55"',
      'serial_number': 'SN-SAMSUNG-TV-001',
      'type': 'tv',
      'status': 'active',
      'created_at': now,
      'updated_at': now,
    },
  ]);

  try {
    // Check if devices table exists and has data
    final result = await conn.execute('SELECT COUNT(*) FROM devices');
    final count = result.first[0] as int;

    if (count == 0) {
      for (final device in devices) {
        await conn.execute(
          r'''
            INSERT INTO devices
              (id, name, serial_number, type, status, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            ON CONFLICT (id) DO NOTHING
          ''',
          parameters: [
            device['id'],
            device['name'],
            device['serial_number'],
            device['type'],
            device['status'],
            device['created_at'],
            device['updated_at'],
          ],
        );
      }
      print('✓ Devices seed data inserted successfully');
    } else {
      print('✓ Devices table already has data, skipping seed');
    }
  } catch (e) {
    print('✗ Error seeding devices: $e');
    rethrow;
  }
}
