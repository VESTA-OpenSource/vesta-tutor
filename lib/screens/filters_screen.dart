import 'package:flutter/material.dart';

class FiltersScreen extends StatelessWidget {
  const FiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Domain Block:", 
            style: TextStyle(color: Color(0xFFA4A9B3), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          const Text(
            "Contenido del módulo de filtros activo...",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}