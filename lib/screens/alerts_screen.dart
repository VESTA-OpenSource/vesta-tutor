import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vesta_app/services/notification_service.dart';

class AlertsScreen extends StatefulWidget {
  final String childId;
  final String tutorId;

  const AlertsScreen({
    super.key,
    required this.childId,
    required this.tutorId,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final NotificationService _notificationService = NotificationService();
  String? _ultimoAlertIdProcesado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "VESTA SECURITY & TRACKING",
            style: TextStyle(color: Color(0xFFE03131), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Acceso jerárquico a la subcolección de alertas
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.tutorId)
                  .collection('hijos')
                  .doc(widget.childId)
                  .collection('alertas')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE03131)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Sin incidentes reportados", style: TextStyle(color: Colors.grey)),
                  );
                }

                final docs = snapshot.data!.docs;

                // Lógica Anti-Spam: Solo notifica si detecta un ID nuevo
                final ultimaAlertaDoc = docs.first;
                if (_ultimoAlertIdProcesado != ultimaAlertaDoc.id) {
                  _ultimoAlertIdProcesado = ultimaAlertaDoc.id;
                  
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final data = ultimaAlertaDoc.data() as Map<String, dynamic>;
                    _notificationService.mostrarNotificacionInmediata(
                      titulo: data['title'] ?? 'Alerta',
                      subtitulo: data['subtitle'] ?? 'Incidente registrado',
                      tipo: data['type'] ?? 'critical',
                    );
                  });
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildAlertaCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertaCard(Map<String, dynamic> data) {
    Color accentColor = data['type'] == 'critical' 
        ? const Color(0xFFE03131) 
        : const Color(0xFFFCC419);
        
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF222630),
        border: Border.all(color: const Color(0xFF3A3F4D)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 60, color: accentColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Alerta',
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data['subtitle'] ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}