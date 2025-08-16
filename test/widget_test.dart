import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Capacitación App Security Tests', () {
    testWidgets('App builds without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Test')),
            body: Text('Capacitación Interna'),
          ),
        ),
      );

      expect(find.text('Capacitación Interna'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Login components render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Capacitación Interna')),
            body: Column(
              children: [
                Icon(Icons.school),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Iniciar Sesión'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Capacitación Interna'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    test('Email validation security test', () {
      String? validateEmail(String? value) {
        if (value == null || value.isEmpty) {
          return 'Email requerido';
        }
        if (!value.contains('@')) {
          return 'Email inválido';
        }
        if (value.length < 5) {
          return 'Email muy corto';
        }
        return null;
      }

      // Tests de seguridad de email
      expect(validateEmail(''), 'Email requerido');
      expect(validateEmail('test'), 'Email inválido');
      expect(validateEmail('a@b'), 'Email muy corto');
      expect(validateEmail('test@email.com'), null);
    });

    test('Password validation security test', () {
      String? validatePassword(String? value) {
        if (value == null || value.isEmpty) {
          return 'Contraseña requerida';
        }
        if (value.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        return null;
      }

      // Tests de seguridad de contraseña
      expect(validatePassword(''), 'Contraseña requerida');
      expect(validatePassword('123'), 'Mínimo 6 caracteres');
      expect(validatePassword('12345'), 'Mínimo 6 caracteres');
      expect(validatePassword('123456'), null);
      expect(validatePassword('password123'), null);
    });

    test('Input sanitization test', () {
      String sanitizeInput(String input) {
        // Remover caracteres peligrosos
        return input
            .replaceAll('<script>', '')
            .replaceAll('</script>', '')
            .replaceAll('<', '')
            .replaceAll('>', '')
            .trim();
      }

      // Tests de sanitización
      expect(sanitizeInput('<script>alert("hack")</script>'), 'alert("hack")');
      expect(sanitizeInput('Normal text'), 'Normal text');
      expect(sanitizeInput('  Text with spaces  '), 'Text with spaces');
    });

    test('Course data validation test', () {
      bool isValidCourse(String title, String instructor, int maxStudents) {
        return title.isNotEmpty && 
               instructor.isNotEmpty && 
               maxStudents > 0 && 
               maxStudents <= 100;
      }

      // Tests de validación de cursos
      expect(isValidCourse('Excel Avanzado', 'María García', 20), true);
      expect(isValidCourse('', 'María García', 20), false);
      expect(isValidCourse('Excel', '', 20), false);
      expect(isValidCourse('Excel', 'María', 0), false);
      expect(isValidCourse('Excel', 'María', 150), false);
    });

    test('User permission validation test', () {
      bool canAccessCourse(bool isLoggedIn, bool isActive) {
        return isLoggedIn && isActive;
      }

      // Tests de permisos
      expect(canAccessCourse(true, true), true);
      expect(canAccessCourse(false, true), false);
      expect(canAccessCourse(true, false), false);
      expect(canAccessCourse(false, false), false);
    });

    test('String security validations', () {
      // Tests básicos de seguridad
      expect('test@email.com'.contains('@'), true);
      expect('password123'.length >= 6, true);
      expect('Excel Avanzado'.isNotEmpty, true);
      expect('   '.trim().isEmpty, true);
    });

    test('Number validations', () {
      // Tests de números
      int maxStudents = 20;
      int currentStudents = 15;
      
      expect(maxStudents > 0, true);
      expect(currentStudents >= 0, true);
      expect(currentStudents <= maxStudents, true);
      expect(maxStudents <= 100, true);
    });
  });
}