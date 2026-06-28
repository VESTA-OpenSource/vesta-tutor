import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vesta_app/main.dart';
import 'package:vesta_app/features/auth/login_screen.dart';

void main() {
  testWidgets('Al iniciar la app, debería mostrar la pantalla de Login', (WidgetTester tester) async {
    // Necesitamos pasar el router configurado desde tu main.dart
    // Nota: Es mejor instanciar AppRouter aquí para controlar la inyección
    await tester.pumpWidget(const MyApp());

    // Esperamos a que la navegación inicial termine
    await tester.pumpAndSettle();

    // Verificamos que estamos en LoginScreen (puedes buscar un texto específico de tu Login)
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}