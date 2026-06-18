import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String childId;
  const MapScreen({super.key, required this.childId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _ultimaUbicacion = const LatLng(11.2404, -74.1990);

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>?;
        final pos = data?['position'] as Map<String, dynamic>?;
        if (pos != null) {
          final newPos = LatLng(pos['latitude'], pos['longitude']);
          if (newPos != _ultimaUbicacion) {
            setState(() => _ultimaUbicacion = newPos);
            _mapController.move(newPos, 16.0);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _ultimaUbicacion,
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            userAgentPackageName: 'org.vestaopensource.tutor',
            // ELIMINADO: retinaMode para evitar el conflicto de versiones
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _ultimaUbicacion,
                child: const Icon(Icons.radar, color: Color(0xFFE03131), size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }
}