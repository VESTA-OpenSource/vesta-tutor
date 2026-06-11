import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:vesta_app/firebase_options.dart';
import 'package:vesta_app/core/router/app_router.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      ),
      routerConfig: router,
    );
  }
}