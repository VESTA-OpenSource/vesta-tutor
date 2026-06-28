import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:vesta_app/firebase_options.dart';
import 'package:vesta_app/core/router/app_router.dart';
import 'package:vesta_app/services/notification_service.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de cualquier llamada asíncrona
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Inicializar servicios de notificaciones
    final notificationService = NotificationService();
    await notificationService.inicializarNotificaciones();
    
  } catch (e) {
    debugPrint("Error al inicializar servicios: $e");
  }

  // 3. Inyectar el router y lanzar la aplicación
  final appRouter = AppRouter();
  runApp(MyApp(router: appRouter.router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VESTA - Panel de Control Parental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1D24),
        primaryColor: const Color(0xFFE03131),
        // Puedes definir tu paleta de colores global aquí
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE03131),
          surface: Color(0xFF1A1D24),
        ),
      ),
      routerConfig: router,
    );
  }
}