import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener este paquete en pubspec.yaml

class ReportsScreen extends StatelessWidget {
  final String childId;
  final String tutorId;

  const ReportsScreen({
    super.key, 
    required this.childId, 
    required this.tutorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      body: StreamBuilder<QuerySnapshot>(
        // Accedemos a la subcolección de reportes del hijo específico
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(tutorId)
            .collection('hijos')
            .doc(childId)
            .collection('reportes')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE03131)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay reportes generados aún.', style: TextStyle(color: Colors.grey)),
            );
          }
          
          final reportes = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final data = reportes[index].data() as Map<String, dynamic>;
              
              // Formateo seguro de fecha
              String fechaStr = 'N/A';
              if (data['fecha'] is Timestamp) {
                fechaStr = DateFormat('dd/MM/yyyy HH:mm').format(data['fecha'].toDate());
              } else if (data['fecha'] != null) {
                fechaStr = data['fecha'].toString();
              }

              return Card(
                color: const Color(0xFF242831),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    data['titulo'] ?? 'Reporte sin nombre', 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text("Generado: $fechaStr", style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.picture_as_pdf, color: Color(0xFFE03131)),
                  onTap: () {
                    // Implementar lógica de visualización de PDF aquí
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}