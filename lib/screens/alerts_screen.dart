import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vesta_app/services/notification_service.dart';

class AlertsScreen extends StatefulWidget {
  final String childId;
  const AlertsScreen({super.key, required this.childId});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final NotificationService _notificationService = NotificationService();
  
  String? _ultimoAlertIdProcesado;

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("VESTA SECURITY & TRACKING", style: TextStyle(color: Color(0xFFE03131), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Alertas Críticas Recientes:", style: TextStyle(color: Color(0xFFA4A9B3), fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Expanded(
            child: uid == null
              ? const Center(child: Text("Inicia sesión para ver alertas"))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('alerts')
                      .where('tutorId', isEqualTo: uid)  
                      .where('childId', isEqualTo: widget.childId) // Se usa widget.childId por estar dentro del State
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error de acceso: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 12)));
                    }
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) return const Center(child: Text("Sin incidentes reportados", style: TextStyle(color: Colors.grey)));
                    
                    // 🛡️ FILTRO INTELIGENTE ANTI-SPAM
                    final ultimaAlertaDoc = docs.first;
                    final String idAlertaActual = ultimaAlertaDoc.id; // El ID único generado por Firestore

                    if (_ultimoAlertIdProcesado != idAlertaActual) {
                      // Registramos la alerta en memoria inmediatamente ANTES del callback para evitar duplicados simultáneos
                      _ultimoAlertIdProcesado = idAlertaActual;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final alertData = ultimaAlertaDoc.data() as Map<String, dynamic>;
                        _notificationService.mostrarNotificacionInmediata(
                          titulo: alertData['title'] ?? 'Incidente Detectado',
                          subtitulo: alertData['subtitle'] ?? 'Se ha registrado una evasión.',
                          tipo: alertData['type'] ?? 'critical',
                        );
                      });
                    }
                    
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final alertData = doc.data() as Map<String, dynamic>; 
                        Color accentColor = const Color(0xFF2B5BDE);
                        Color titleColor = const Color(0xFF4DABF7);
                        
                        if (alertData['type'] == 'critical') {
                          accentColor = const Color(0xFFE03131);
                          titleColor = const Color(0xFFFF6B6B);
                        } else if (alertData['type'] == 'warning') {
                          accentColor = const Color(0xFFFCC419);
                          titleColor = const Color(0xFFFCC419);
                        }
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222630),
                            border: Border.all(color: const Color(0xFF3A3F4D)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Container(width: 6, height: 80, color: accentColor),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alertData['title'] ?? 'Alerta', 
                                        style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 13)
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        alertData['subtitle'] ?? '', 
                                        style: const TextStyle(color: Color(0xFFA4A9B3), fontSize: 11)
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}