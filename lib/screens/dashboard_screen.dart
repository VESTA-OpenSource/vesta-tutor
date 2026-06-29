import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      appBar: AppBar(
        title: const Text(
          '🎯 PANEL DE CONTROL VESTA',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF111318),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFE03131)),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: uid != null
            ? FirebaseFirestore.instance.collection('users').doc(uid).collection('hijos').snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE03131)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has registrado ningún menor.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            );
          }
          final hijos = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: hijos.length,
            itemBuilder: (context, index) {
              final doc = hijos[index];
              final hijo = doc.data() as Map<String, dynamic>;
              final hijoId = doc.id;
              bool estaVinculado = hijo['status'] == 'vinculado';
              
              return Card(
                color: const Color(0xFF242831),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    estaVinculado ? Icons.link : Icons.link_off,
                    color: estaVinculado ? Colors.green : const Color(0xFFE03131),
                  ),
                  title: Text(hijo['nombre'] ?? 'Sin nombre', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Estado: ${estaVinculado ? "Vinculado" : "Esperando vinculación"}', 
                      style: TextStyle(color: Colors.grey.shade600)),
                  onTap: () {
                    // VALIDACIÓN: Solo entramos si está vinculado
                    if (estaVinculado) {
                      context.go('/home/$hijoId', extra: hijo['nombre']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El menor aún no está vinculado.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE03131),
        onPressed: () => context.go('/add-child'),
        child: const Icon(Icons.add),
      ),
    );
  }
}