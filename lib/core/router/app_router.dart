import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vesta_app/screens/home_screen.dart';
import 'package:vesta_app/features/auth/login_screen.dart';
import 'package:vesta_app/features/auth/register_screen.dart';
import 'package:vesta_app/screens/filters_screen.dart';
import 'package:vesta_app/screens/alerts_screen.dart';
import 'package:vesta_app/screens/reports_screen.dart';

class AppRouter {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  late final GoRouter router = GoRouter(
    initialLocation: '/login', 
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    redirect: (context, state) async {
      final user = auth.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      // 1. Si no está logueado y no está en login/registro, obligar a ir a /login
      if (user == null) {
        if (isLoggingIn || isRegistering) return null;
        return '/login';
      }

      // 2. Si ya está logueado e intenta ir a login o registro, redirigir al Home (/)
      if (isLoggingIn || isRegistering) {
        return '/'; 
      }

      try {
        final doc = await db.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('role')) {
          final role = doc['role'];
          if (role == 'student') {
            return null; 
          }
        }
      } catch (e) {
        return null;
      }

      return null; 
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/filters',
        builder: (context, state) => const FiltersScreen(),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}