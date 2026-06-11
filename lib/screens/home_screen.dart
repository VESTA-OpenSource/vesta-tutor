import 'package:flutter/material.dart';
import 'package:vesta_app/services/auth_service.dart';
import 'package:vesta_app/screens/filters_screen.dart';
import 'package:vesta_app/screens/alerts_screen.dart';
import 'package:vesta_app/screens/reports_screen.dart';

import 'package:vesta_app/widgets/vesta_header.dart';
import 'package:vesta_app/widgets/vesta_navbar.dart';

import 'filters_screen.dart';
import 'alerts_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0; 

  // Listado de las vistas reales conectadas a Firebase
  final List<Widget> _screens = [
    const FiltersScreen(),
    const AlertsScreen(),
    const ReportsScreen(),
  ];

  final List<String> _tabNames = ["Filtros", "Alertas", "Reportes"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Global Superior (Logotipo y Escudo)
            const VestaHeader(isDark: true),

            // 2. Barra de Navegación Interactiva modificada para controlar pestañas
            _buildVestaNavbar(),

            // 3. Contenedor Dinámico de la Pantalla Seleccionada
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: _screens,
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
          _navButton("Filtros", 0),
          _navButton("Alertas", 1),
          _navButton("Reportes", 2),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF3A3F4D),
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                await auth.signOut();
              },
              child: const Text(
                "Salir",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
        onPressed: () {
          setState(() {
            _currentTabIndex = index;
          });
        },
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}