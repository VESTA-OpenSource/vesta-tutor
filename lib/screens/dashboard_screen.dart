import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vesta_app/services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _desvincularHijo(BuildContext context, String uid, String hijoId) async {
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      final hijoRef = db.collection('users').doc(uid).collection('hijos').doc(hijoId);
      final telemetriaRef = db.collection('telemetria').doc(hijoId);

      // Actualizamos estado. Usamos set con merge: true para evitar errores si el doc no existe
      batch.update(hijoRef, {'status': 'esperando_vinculacion'});
      
      // Intentamos actualizar la telemetría, si no existe no detiene el proceso
      batch.set(telemetriaRef, {'status': 'inactivo'}, SetOptions(merge: true));

      await batch.commit();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menor desvinculado correctamente')),
        );
      }
    } catch (e) {
      debugPrint("Error al desvincular: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al desvincular: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      appBar: AppBar(
        title: const Text('🎯 PANEL DE CONTROL VESTA', 
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF111318),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () => AuthService().signOut(),
          )
        ],
      ),
      body: user == null 
        ? const Center(child: Text("Inicia sesión para continuar", style: TextStyle(color: Colors.white)))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('hijos')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFE03131)));
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No tienes menores registrados.", style: TextStyle(color: Colors.grey)));
              }
              
              final hijos = snapshot.data!.docs;
              
              return ListView.builder(
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado: ${estaVinculado ? "Vinculado" : "Esperando vinculación"}', 
                              style: TextStyle(color: Colors.grey.shade600)),
                          if (!estaVinculado) 
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Código: ${hijo['pairingCode'] ?? 'N/A'}', 
                                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      trailing: estaVinculado 
                        ? IconButton(
                            icon: const Icon(Icons.link_off, color: Colors.amber),
                            onPressed: () => _desvincularHijo(context, user.uid, hijoId),
                          )
                        : null,
                      onTap: () {
                        if (estaVinculado) {
                          context.go('/home/$hijoId', extra: hijo['nombre']);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El menor aún no está vinculado.')));
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