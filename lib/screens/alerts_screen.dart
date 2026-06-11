import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

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
                      .collection('users')
                      .doc(uid)
                      .collection('alerts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) return const Center(child: Text("Sin incidentes reportados", style: TextStyle(color: Colors.grey)));

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        Color accentColor = const Color(0xFF2B5BDE);
                        Color titleColor = const Color(0xFF4DABF7);
                        
                        if (doc['type'] == 'critical') {
                          accentColor = const Color(0xFFE03131);
                          titleColor = const Color(0xFFFF6B6B);
                        } else if (doc['type'] == 'warning') {
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
                                      Text(doc['title'], style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text(doc['subtitle'], style: const TextStyle(color: Color(0xFFA4A9B3), fontSize: 11)),
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