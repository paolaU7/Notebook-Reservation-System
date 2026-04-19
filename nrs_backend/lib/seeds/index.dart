// ignore_for_file: public_member_api_docs

import 'package:nrs_backend/seeds/device_seed.dart';

/// Entry point for running all database seeds
Future<void> runSeeds() async {
  try {
    print('Starting database seeding...\n');

    await seedDevices();

    print('\n✓ Database seeding completed successfully');
  } catch (e) {
    print('\n✗ Database seeding failed: $e');
    rethrow;
  }
}
