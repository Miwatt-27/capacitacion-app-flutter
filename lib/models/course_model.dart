class CourseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String instructor;
  final DateTime startDate;
  final DateTime endDate;
  final int maxStudents;
  final int currentStudents;
  final bool isActive;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.instructor,
    required this.startDate,
    required this.endDate,
    required this.maxStudents,
    this.currentStudents = 0,
    this.isActive = true,
  });

  // Convertir desde Firebase a CourseModel
  factory CourseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CourseModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      instructor: map['instructor'] ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
      maxStudents: map['maxStudents'] ?? 0,
      currentStudents: map['currentStudents'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'instructor': instructor,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'maxStudents': maxStudents,
      'currentStudents': currentStudents,
      'isActive': isActive,
    };
  }

  // Crear copia con cambios
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? instructor,
    DateTime? startDate,
    DateTime? endDate,
    int? maxStudents,
    int? currentStudents,
    bool? isActive,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      instructor: instructor ?? this.instructor,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxStudents: maxStudents ?? this.maxStudents,
      currentStudents: currentStudents ?? this.currentStudents,
      isActive: isActive ?? this.isActive,
    );
  }

  // Verificar si hay cupos disponibles
  bool get hasAvailableSpots => currentStudents < maxStudents;
  
  // Porcentaje de ocupación
  double get occupancyPercentage => maxStudents > 0 ? (currentStudents / maxStudents) * 100 : 0;
}