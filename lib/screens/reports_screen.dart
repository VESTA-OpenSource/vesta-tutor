import 'package:flutter/material.dart';
class ReportsScreen extends StatelessWidget {
  final String childId;
  const ReportsScreen({super.key, required this.childId}); 
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Módulo de Reportes en Desarrollo", 
        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}