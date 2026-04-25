/// Modelos de datos para NRS Frontend
/// 
/// Contiene las clases que representan las entidades del sistema

/// Modelo para un usuario autenticado
class AuthUser {
  final String id;
  final String email;
  final String role; // 'admin', 'teacher', 'student'
  final String? name;
  final String? token;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      name: json['name'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'token': token,
    };
  }
}

/// Modelo para un notebook/dispositivo
class Device {
  final String id;
  final String name;
  final String type; // 'notebook', 'tablet', etc.
  final String? serial;
  final String? model;
  final String status; // 'available', 'checked_out', 'maintenance', etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Device({
    required this.id,
    required this.name,
    required this.type,
    this.serial,
    this.model,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      serial: json['serial'] as String?,
      model: json['model'] as String?,
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'serial': serial,
      'model': model,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Modelo para una reserva
class Reservation {
  final String id;
  final String userId;
  final String deviceId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'pending', 'active', 'completed', 'cancelled'
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      startDate: DateTime.parse(json['start_date'] as String? ?? ''),
      endDate: DateTime.parse(json['end_date'] as String? ?? ''),
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_id': deviceId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Modelo para un checkout (entrega)
class Checkout {
  final String id;
  final String reservationId;
  final String deviceId;
  final String userId;
  final DateTime checkedOutAt;
  final String status; // 'pending', 'confirmed', 'returned'
  final String? deviceNotes;
  final DateTime? createdAt;

  Checkout({
    required this.id,
    required this.reservationId,
    required this.deviceId,
    required this.userId,
    required this.checkedOutAt,
    required this.status,
    this.deviceNotes,
    this.createdAt,
  });

  factory Checkout.fromJson(Map<String, dynamic> json) {
    return Checkout(
      id: json['id'] as String? ?? '',
      reservationId: json['reservation_id'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      checkedOutAt: DateTime.parse(json['checked_out_at'] as String? ?? ''),
      status: json['status'] as String? ?? 'pending',
      deviceNotes: json['device_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'device_id': deviceId,
      'user_id': userId,
      'checked_out_at': checkedOutAt.toIso8601String(),
      'status': status,
      'device_notes': deviceNotes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Modelo para una devolución
class Return {
  final String id;
  final String checkoutId;
  final String deviceId;
  final String userId;
  final DateTime returnedAt;
  final String condition; // 'good', 'damaged', 'lost'
  final String? notes;
  final DateTime? createdAt;

  Return({
    required this.id,
    required this.checkoutId,
    required this.deviceId,
    required this.userId,
    required this.returnedAt,
    required this.condition,
    this.notes,
    this.createdAt,
  });

  factory Return.fromJson(Map<String, dynamic> json) {
    return Return(
      id: json['id'] as String? ?? '',
      checkoutId: json['checkout_id'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      returnedAt: DateTime.parse(json['returned_at'] as String? ?? ''),
      condition: json['condition'] as String? ?? 'good',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkout_id': checkoutId,
      'device_id': deviceId,
      'user_id': userId,
      'returned_at': returnedAt.toIso8601String(),
      'condition': condition,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Modelo para un estudiante
class Student {
  final String id;
  final String email;
  final String name;
  final String dni;
  final int year; // 1-7
  final int division; // 1-10
  final String? specialty; // Para ciclo superior
  final bool isActive;
  final DateTime? createdAt;

  Student({
    required this.id,
    required this.email,
    required this.name,
    required this.dni,
    required this.year,
    required this.division,
    this.specialty,
    this.isActive = true,
    this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      year: json['year'] as int? ?? 1,
      division: json['division'] as int? ?? 1,
      specialty: json['specialty'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'dni': dni,
      'year': year,
      'division': division,
      'specialty': specialty,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Modelo para un docente
class Teacher {
  final String id;
  final String email;
  final String name;
  final String dni;
  final bool isActive;
  final DateTime? createdAt;

  Teacher({
    required this.id,
    required this.email,
    required this.name,
    required this.dni,
    this.isActive = true,
    this.createdAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'dni': dni,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Modelo para un elemento en la lista de supervisión
class WatchlistItem {
  final String id;
  final String deviceId;
  final String reason;
  final DateTime createdAt;
  final String? notes;

  WatchlistItem({
    required this.id,
    required this.deviceId,
    required this.reason,
    required this.createdAt,
    this.notes,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String? ?? ''),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
    };
  }
}
