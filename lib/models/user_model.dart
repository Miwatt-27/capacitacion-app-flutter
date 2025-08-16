class UserModel {
  final String id;
  final String email;
  final String name;
  final String department;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.department,
    required this.createdAt,
    required this.isActive,
  });

  // Convertir desde Firebase (Map) a UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isActive: map['isActive'] ?? true,
    );
  }

  // Convertir desde UserModel a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'department': department,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  // Crear copia con cambios
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? department,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}