// ignore_for_file: public_member_api_docs

import 'package:bcrypt/bcrypt.dart';
import 'package:nrs_backend/database/connection.dart';
import 'package:nrs_backend/models/teacher.dart';
import 'package:ulid/ulid.dart';

class TeacherRepository {
  Future<Teacher?> findByEmail(String email) async {
    final conn = await getConnection();
    final result = await conn.execute(
      r'''
        SELECT id, full_name, email, dni, created_at
        FROM teachers WHERE email = $1
      ''',
      parameters: [email],
    );
    if (result.isEmpty) return null;
    return Teacher.fromRow(result.first);
  }

  Future<bool> existsByEmail(String email) async {
    return (await findByEmail(email)) != null;
  }

  Future<bool> existsByDni(String dni) async {
    final conn = await getConnection();
    final result = await conn.execute(
      r'SELECT id FROM teachers WHERE dni = $1',
      parameters: [dni],
    );
    return result.isNotEmpty;
  }

  Future<Teacher> create({
    required String fullName,
    required String email,
    required String dni,
  }) async {
    final conn = await getConnection();
    final id           = Ulid().toString();
    final passwordHash = BCrypt.hashpw(dni, BCrypt.gensalt());

    await conn.execute(
      r'''
        INSERT INTO teachers
          (id, full_name, email, dni, password_hash)
        VALUES ($1, $2, $3, $4, $5)
      ''',
      parameters: [id, fullName, email, dni, passwordHash],
    );

    return (await findByEmail(email))!;
  }

  Future<Teacher?> login({
    required String email,
    required String dni,
  }) async {
    final conn = await getConnection();
    final result = await conn.execute(
      r'''
        SELECT id, full_name, email, dni, password_hash, created_at
        FROM teachers WHERE email = $1
      ''',
      parameters: [email],
    );

    if (result.isEmpty) return null;

    final row          = result.first;
    final passwordHash = row[4]! as String;
    final isValid      = BCrypt.checkpw(dni, passwordHash);

    if (!isValid) return null;

    return Teacher(
      id:        row[0]! as String,
      fullName:  row[1]! as String,
      email:     row[2]! as String,
      dni:       row[3]! as String,
      createdAt: row[5]! as DateTime,
    );
  }

  Future<List<Teacher>> getAll() async {
    final conn = await getConnection();
    final result = await conn.execute(
      'SELECT id, full_name, email, dni, created_at FROM teachers',
    );
    return result.map(Teacher.fromRow).toList();
  }
}
