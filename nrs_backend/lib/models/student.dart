// ignore_for_file: public_member_api_docs

class Student {
  Student({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dni,
    required this.year,
    required this.division,
    required this.isActive,
    required this.createdAt,
  });

  factory Student.fromRow(List<dynamic> row) {
    return Student(
      id:        row[0] as String,
      fullName:  row[1] as String,
      email:     row[2] as String,
      dni:       row[3] as String,
      year:      row[4] as int,
      division:  row[5] as int,
      isActive:  row[6] as bool,
      createdAt: row[7] as DateTime,
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String dni;
  final int year;
  final int division;
  final bool isActive;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id':         id,
    'full_name':  fullName,
    'email':      email,
    'dni':        dni,
    'year':       year,
    'division':   division,
    'is_active':  isActive,
    'created_at': createdAt.toIso8601String(),
  };
}
