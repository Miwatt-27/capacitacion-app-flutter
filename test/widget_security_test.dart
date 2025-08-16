import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Security Tests', () {
    testWidgets('Login form prevents empty submission', (WidgetTester tester) async {
      bool formSubmitted = false;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Email requerido';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formSubmitted = true;
                      }
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Intentar enviar formulario vacío
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verificar que no se envió
      expect(formSubmitted, false);
      expect(find.text('Email requerido'), findsOneWidget);
    });

    testWidgets('Course card displays safely', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: ListTile(
                title: Text('Excel Avanzado'),
                subtitle: Text('Instructor: María García'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Ver detalles'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Excel Avanzado'), findsOneWidget);
      expect(find.text('Instructor: María García'), findsOneWidget);
      expect(find.text('Ver detalles'), findsOneWidget);
    });

    testWidgets('Navigation security test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Cursos'),
                BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Mis Cursos'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Cursos'), findsOneWidget);
      expect(find.text('Mis Cursos'), findsOneWidget);
    });
  });
}