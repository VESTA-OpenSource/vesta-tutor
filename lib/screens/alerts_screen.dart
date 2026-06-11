import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AlertsScreen extends StatelessWidget {
  final String childId;
  const AlertsScreen({super.key, required this.childId});
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
                      .where('childId', isEqualTo: childId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) return const Center(child: Text("Sin incidentes reportados", style: TextStyle(color: Colors.grey)));
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