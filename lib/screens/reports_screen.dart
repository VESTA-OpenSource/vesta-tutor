import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  final String childId;

  const ReportsScreen({super.key, required this.childId}); 

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 🚀 Las 3 vistas del requerimiento RF-05
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1D24),
        appBar: AppBar(
          backgroundColor: const Color(0xFF14171C),
          elevation: 0,
          toolbarHeight: 12, // Minimiza el AppBar para darle prioridad a los tabs
          bottom: const TabBar(
            indicatorColor: Color(0xFFE03131),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            tabs: [
              Tab(icon: Icon(Icons.timeline, size: 18), text: "ACTIVIDAD"),
              Tab(icon: Icon(Icons.block, size: 18), text: "BLOQUEADOS"),
              Tab(icon: Icon(Icons.gpp_bad, size: 18), text: "INTENTOS"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActividadDiaria(),
            _buildSitiosBloqueados(),
            _buildIntentosAcceso(),
          ],
        ),
      ),
    );
  }

  // 📊 1. Vista: Actividad Diaria (Línea de tiempo de eventos/rutas)
  Widget _buildActividadDiaria() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('telemetria')
          .doc(childId)
          .collection('historial')
          .orderBy('timestamp', descending: true)
          .limit(15)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE03131)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("Sin registros de actividad para hoy.");
        }

        final logs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final data = logs[index].data() as Map<String, dynamic>;
            final DateTime timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            final String hora = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
            final String evento = data['evento'] ?? 'Actualización de Posición';

            return Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE03131),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index != logs.length - 1)
                      Container(width: 2, height: 45, color: const Color(0xFF323743)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: const Color(0xFF242831),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(evento, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text("Lat: ${data['latitude'] ?? 0.0} | Long: ${data['longitude'] ?? 0.0}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      trailing: Text(hora, style: const TextStyle(color: Color(0xFFE03131), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🚫 2. Vista: Sitios Bloqueados (Lista negra de URLs configuradas)
  Widget _buildSitiosBloqueados() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hijos_config')
          .doc(childId)
          .collection('sitios_bloqueados')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE03131)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("No hay restricciones web configuradas.");
        }

        final sitios = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sitios.length,
          itemBuilder: (context, index) {
            final data = sitios[index].data() as Map<String, dynamic>;
            return Card(
              color: const Color(0xFF242831),
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.link_off, color: Colors.grey, size: 20),
                title: Text(data['url'] ?? 'Dominio no especificado', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text("Categoría: ${data['categoria'] ?? 'Filtro General'}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                trailing: const Icon(Icons.lock, color: Color(0xFFE03131), size: 16),
              ),
            );
          },
        );
      },
    );
  }

  // ⚠️ 3. Vista: Intentos de Acceso (Historial de alertas de navegación prohibida)
  Widget _buildIntentosAcceso() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('logs_seguridad')
          .where('childId', isEqualTo: childId)
          .where('tipo', isEqualTo: 'bloqueo_web')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE03131)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("Excelente: 0 intentos de violación de red.");
        }

        final intentos = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: intentos.length,
          itemBuilder: (context, index) {
            final data = intentos[index].data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            final String fechaFormateada = "${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
            
            return Card(
              color: const Color(0xFF2B1E1E), // Fondo rojizo sutil de alerta táctica
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFE03131), width: 0.5),
                borderRadius: BorderRadius.circular(8)
              ),
              child: ListTile(
                leading: const Icon(Icons.warning, color: Color(0xFFE03131), size: 20),
                title: Text("Acceso denegado a: ${data['url'] ?? 'Desconocido'}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text("Marcador de tiempo: $fechaFormateada", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE03131), borderRadius: BorderRadius.circular(4)),
                  child: const Text("BLOCK", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget utilitario para pantallas sin datos
  Widget _buildEmptyState(String mensaje) {
    return Center(
      child: Text(
        mensaje,
        style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
      ),
    );
  }
}