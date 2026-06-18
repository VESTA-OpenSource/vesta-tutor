import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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
        stream: FirebaseFirestore.instance
            .collection('users') 
            .doc(uid)
            .collection('hijos')
            .snapshots(),
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
              
              // Verificamos si está vinculado
              bool estaVinculado = hijo['status'] == 'vinculado';

              return Card(
                color: const Color(0xFF242831),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1A1D24),
                    child: Icon(
                      estaVinculado ? Icons.link : Icons.link_off, 
                      color: estaVinculado ? Colors.green : const Color(0xFFE03131)
                    ),
                  ),
                  title: Text(
                    hijo['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Código: ${hijo['pairingCode'] ?? 'GENERANDO...'}',
                        style: TextStyle(
                          color: estaVinculado ? Colors.green.shade200 : Colors.amber.shade200,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Estado: ${estaVinculado ? "Vinculado" : "Esperando vinculación"}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFE03131)),
                    onPressed: () => _confirmarEliminacion(context, uid!, hijoId),
                  ),
                  onTap: () {
                    context.go('/home/$hijoId', extra: hijo['nombre']);
                  },
                ),
              );
            }, 
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE03131),
        foregroundColor: Colors.white,
        onPressed: () {
          context.go('/add-child');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, String uid, String hijoId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF242831),
        title: const Text('¿Eliminar perfil?', style: TextStyle(color: Colors.white)),
        content: const Text('Esta acción no se puede deshacer.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('hijos')
                  .doc(hijoId)
                  .delete();
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFE03131))),
          ),
        ],
      ),
    );
  }
}