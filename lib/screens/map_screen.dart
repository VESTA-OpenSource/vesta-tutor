import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String childId;
  final String tutorId; 
  
  const MapScreen({
    super.key, 
    required this.childId, 
    required this.tutorId
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _ultimaUbicacion = const LatLng(11.2404, -74.1990);
  String _lastUpdate = "Esperando señal...";
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _iniciarEscuchaUbicacion();
  }

  void _iniciarEscuchaUbicacion() {
    _locationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.tutorId)
        .collection('hijos')
        .doc(widget.childId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data();
        final pos = data?['position'] as Map<String, dynamic>?;
        final timestamp = data?['timestamp'] as Timestamp?;
        
        if (pos != null) {
          final newPos = LatLng(
            (pos['latitude'] as num).toDouble(), 
            (pos['longitude'] as num).toDouble()
          );
          
          setState(() {
            _ultimaUbicacion = newPos;
            if (timestamp != null) {
              _lastUpdate = DateFormat('HH:mm:ss').format(timestamp.toDate());
            }
          });
          
          // Movemos el mapa suavemente
          _mapController.move(newPos, 16.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ubicación en Tiempo Real", style: TextStyle(fontSize: 16)),
            Text(
              "Última señal: $_lastUpdate", 
              style: const TextStyle(fontSize: 11, color: Colors.grey)
            ),
          ],
        ),
        backgroundColor: const Color(0xFF111318),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _ultimaUbicacion,
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            // El mapa oscuro de CartoDB es ideal para el modo noche de tu app
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _ultimaUbicacion,
                width: 40,
                height: 40,
                child: const Icon(Icons.radar, color: Color(0xFFE03131), size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}