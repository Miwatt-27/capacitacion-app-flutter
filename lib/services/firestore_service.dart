import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CURSOS - OPERACIONES CRUD

  // CREAR CURSO (CREATE)
  Future<String?> createCourse(CourseModel course) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('courses')
          .add(course.toMap());
      
      notifyListeners();
      return docRef.id;
    } catch (e) {
      print('Error creando curso: $e');
      return null;
    }
  }

  // OBTENER TODOS LOS CURSOS (READ)
  Stream<List<CourseModel>> getCourses() {
    return _firestore
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CourseModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // OBTENER CURSO POR ID (READ)
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .get();

      if (doc.exists) {
        return CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error obteniendo curso: $e');
      return null;
    }
  }

  // ACTUALIZAR CURSO (UPDATE)
  Future<bool> updateCourse(String courseId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .update(updates);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error actualizando curso: $e');
      return false;
    }
  }

  // ELIMINAR CURSO (DELETE - soft delete)
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .update({'isActive': false});
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error eliminando curso: $e');
      return false;
    }
  }

  // INSCRIPCIONES - OPERACIONES CRUD

  // INSCRIBIRSE A CURSO (CREATE)
  Future<bool> enrollInCourse(String userId, String courseId) async {
    try {
      // Verificar si ya está inscrito
      QuerySnapshot existing = await _firestore
          .collection('enrollments')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (existing.docs.isNotEmpty) {
        print('Usuario ya inscrito en este curso');
        return false;
      }

      // Crear inscripción
      await _firestore.collection('enrollments').add({
        'userId': userId,
        'courseId': courseId,
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': 0,
        'status': 'active',
        'completedAt': null,
      });

      // Incrementar contador de estudiantes del curso
      await _firestore.collection('courses').doc(courseId).update({
        'currentStudents': FieldValue.increment(1),
      });

      notifyListeners();
      return true;
    } catch (e) {
      print('Error en inscripción: $e');
      return false;
    }
  }

  // OBTENER CURSOS DEL USUARIO (READ)
  Stream<List<Map<String, dynamic>>> getUserEnrollments(String userId) {
    return _firestore
        .collection('enrollments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> enrollments = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> enrollment = doc.data();
        enrollment['id'] = doc.id;
        
        // Obtener datos del curso
        CourseModel? course = await getCourseById(enrollment['courseId']);
        if (course != null) {
          enrollment['course'] = course;
          enrollments.add(enrollment);
        }
      }
      
      return enrollments;
    });
  }

  // ACTUALIZAR PROGRESO (UPDATE)
  Future<bool> updateProgress(String enrollmentId, int progress) async {
    try {
      Map<String, dynamic> updates = {'progress': progress};
      
      // Si completó el curso (100%), marcar fecha de finalización
      if (progress >= 100) {
        updates['status'] = 'completed';
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('enrollments')
          .doc(enrollmentId)
          .update(updates);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error actualizando progreso: $e');
      return false;
    }
  }

  // CANCELAR INSCRIPCIÓN (DELETE)
  Future<bool> cancelEnrollment(String enrollmentId, String courseId) async {
    try {
      // Eliminar inscripción
      await _firestore
          .collection('enrollments')
          .doc(enrollmentId)
          .delete();

      // Decrementar contador de estudiantes del curso
      await _firestore.collection('courses').doc(courseId).update({
        'currentStudents': FieldValue.increment(-1),
      });

      notifyListeners();
      return true;
    } catch (e) {
      print('Error cancelando inscripción: $e');
      return false;
    }
  }

  // BUSCAR CURSOS (READ con filtros)
  Stream<List<CourseModel>> searchCourses(String searchTerm) {
    return _firestore
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
          .where((course) =>
              course.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
              course.category.toLowerCase().contains(searchTerm.toLowerCase()) ||
              course.instructor.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }
}