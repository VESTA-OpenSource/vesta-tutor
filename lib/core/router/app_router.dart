import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vesta_app/screens/home_screen.dart';
import 'package:vesta_app/features/auth/login_screen.dart';
import 'package:vesta_app/features/auth/register_screen.dart';
import 'package:vesta_app/features/auth/forgot_password_screen.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:vesta_app/screens/filters_screen.dart';
import 'package:vesta_app/screens/alerts_screen.dart';
import 'package:vesta_app/screens/reports_screen.dart';
import 'package:vesta_app/screens/dashboard_screen.dart';
import 'package:vesta_app/screens/add_child_screen.dart';

class AppRouter {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    errorBuilder: (context, state) => const DashboardScreen(),
    redirect: (context, state) async {
      final user = auth.currentUser;
      final String Location = state.matchedLocation;

      final bool isLoggingIn = Location == '/login';
      final bool isRegistering = Location == '/register';
      final bool isForgotPassword = Location == '/forgot-password';

      if (user == null) {
        // Permitimos acceso a login, registro y recuperación de contraseña sin estar autenticado
        if (isLoggingIn || isRegistering || isForgotPassword) return null;
        return '/login';
      }
      if (isLoggingIn || isRegistering || isForgotPassword) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password', 
        builder: (context, state) => const ForgotPasswordScreen()
      ),
      GoRoute(
        path: '/add-child',
        builder: (context, state) => AddChildScreen(childData: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/home/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId'] ?? '';
          if (childId.isEmpty) return const DashboardScreen();
          
          final extra = state.extra;
          String childName = (extra is Map<String, dynamic>) ? (extra['childName'] ?? 'Menor') : (extra as String? ?? 'Menor');

          return HomeScreen(
            childId: childId,
            childName: childName,
            tutorId: auth.currentUser?.uid ?? '',
          );
        },
      ),
      ...['filters', 'alerts', 'reports'].map((route) => GoRoute(
        path: '/$route/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId'] ?? '';
          final tutorId = auth.currentUser?.uid ?? '';
          
          switch (route) {
            case 'filters': return FiltersScreen(childId: childId, tutorId: tutorId);
            case 'alerts': return AlertsScreen(childId: childId, tutorId: tutorId);
            case 'reports': return ReportsScreen(childId: childId, tutorId: tutorId);
            default: return const DashboardScreen();
          }
        },
      )),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}