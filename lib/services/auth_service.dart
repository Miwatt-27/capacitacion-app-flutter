import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Usuario actual
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // CREAR USUARIO (CREATE)
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String department,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear perfil de usuario en Firestore
      if (result.user != null) {
        UserModel newUser = UserModel(
          id: result.user!.uid,
          email: email,
          name: name,
          department: department,
          createdAt: DateTime.now(),
          isActive: true,
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());
      }

      notifyListeners();
      return result;
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  // INICIAR SESIÓN (READ)
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return result;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // OBTENER DATOS DEL USUARIO (READ)
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error obteniendo datos de usuario: $e');
      return null;
    }
  }

  // ACTUALIZAR PERFIL DE USUARIO (UPDATE)
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? department,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (department != null) updates['department'] = department;

      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error actualizando perfil: $e');
      return false;
    }
  }

  // CERRAR SESIÓN (DELETE de sesión)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Error cerrando sesión: $e');
    }
  }

  // ELIMINAR CUENTA (DELETE)
  Future<bool> deleteAccount() async {
    try {
      String userId = currentUser!.uid;
      
      // Eliminar datos de Firestore
      await _firestore.collection('users').doc(userId).delete();
      
      // Eliminar cuenta de Authentication
      await currentUser!.delete();
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error eliminando cuenta: $e');
      return false;
    }
  }

  // RESETEAR CONTRASEÑA
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error enviando reset de contraseña: $e');
      return false;
    }
  }
}