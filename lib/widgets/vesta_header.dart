import 'package:flutter/material.dart';
class VestaHeader extends StatelessWidget {
  final bool isDark;
  const VestaHeader({super.key, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.security, 
          size: 60,
          color: Color(0xFFE03131), 
        ),
        const SizedBox(height: 10),
        Text(
          "VESTA",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: isDark ? Colors.white : const Color(0xFF1A1D24),
          ),
        ),
        Text(
          "Guardián de Contenido Digital",
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }
}