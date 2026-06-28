import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesta_app/services/auth_service.dart';
import 'package:vesta_app/screens/map_screen.dart';
import 'package:vesta_app/screens/filters_screen.dart';
import 'package:vesta_app/screens/alerts_screen.dart';
import 'package:vesta_app/screens/reports_screen.dart';
import 'package:vesta_app/widgets/vesta_header.dart';

class HomeScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String tutorId;
  
  const HomeScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.tutorId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Definición de pantallas inyectando los IDs necesarios
    final List<Widget> screens = [
      MapScreen(childId: widget.childId, tutorId: widget.tutorId),
      FiltersScreen(childId: widget.childId, tutorId: widget.tutorId),
      AlertsScreen(childId: widget.childId, tutorId: widget.tutorId),
      ReportsScreen(childId: widget.childId, tutorId: widget.tutorId),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const VestaHeader(isDark: true),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: const Color(0xFF14171C),
                  child: Text(
                    'PERFIL: ${widget.childName.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildVestaNavbar(),
                Expanded(
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 85,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFFE03131),
                onPressed: () => context.go('/'), // Vuelve al dashboard
                child: const Icon(Icons.people_alt_outlined, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVestaNavbar() {
    final auth = AuthService();
    return Container(
      color: const Color(0xFF222630),
      child: Row(
        children: [
          _navButton("Mapa", 0),
          _navButton("Filtros", 1),
          _navButton("Alertas", 2),
          _navButton("Reportes", 3),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF3A3F4D),
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                await auth.signOut();
                // No necesitamos context.go('/login') aquí porque
                // tu AppRouter está escuchando authStateChanges()
              },
              child: const Text(
                "Salir",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(String title, int index) {
    final bool isActive = _currentTabIndex == index;
    final color = isActive ? const Color(0xFFE03131) : const Color(0xFF222630);
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color,
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => setState(() => _currentTabIndex = index),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}