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
import 'package:vesta_app/screens/dashboard_screen.dart';
import 'package:vesta_app/screens/add_child_screen.dart';
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
      if (user == null) {
        if (isLoggingIn || isRegistering) return null;
        return '/login';
      }
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
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/add-child',
        builder: (context, state) {
          final childData = state.extra as Map<String, dynamic>?;
          return AddChildScreen(childData: childData);
        },
      ),
      GoRoute(
        path: '/home/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          final childName = state.extra as String? ?? 'Menor';
          return HomeScreen(childId: childId, childName: childName);
        },
      ),
      GoRoute(
        path: '/filters/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          return FiltersScreen(childId: childId);
        },
      ),
      GoRoute(
        path: '/alerts/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          return AlertsScreen(childId: childId);
        },
      ),
      GoRoute(
        path: '/reports/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          return ReportsScreen(childId: childId);
        },
      ),
    ],
  );
}
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}