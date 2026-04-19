// ignore_for_file: public_member_api_docs

class Device {
  Device({
    required this.id,
    required this.name,
    required this.serialNumber,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Device.fromRow(List<dynamic> row) {
    return Device(
      id: row[0] as String,
      name: row[1] as String,
      serialNumber: row[2] as String,
      type: row[3] as String,
      status: row[4] as String,
      createdAt: row[5] as DateTime,
      updatedAt: row[6] as DateTime,
    );
  }

  final String id;
  final String name;
  final String serialNumber;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'serial_number': serialNumber,
    'type': type,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
