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
      appBar: AppBar(
        title: const Text('Panel de VESTA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aún no has registrado ningún menor.'),
            );
          }
          final hijos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: hijos.length,
            itemBuilder: (context, index) {
              final doc = hijos[index]; 
              final hijo = doc.data() as Map<String, dynamic>;
              final hijoId = doc.id; 
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(hijo['nombre'] ?? 'Sin nombre'),
                  subtitle: Text('Edad: ${hijo['edad'] ?? 0} años'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          context.go('/add-child', extra: {
                            'id': hijoId,
                            'nombre': hijo['nombre'],
                            'edad': hijo['edad'],
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarEliminacion(context, uid!, hijoId),
                      ),
                    ],
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
        title: const Text('¿Eliminar perfil?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
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
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}