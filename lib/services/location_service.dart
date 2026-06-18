import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📡 Transmite la ubicación en vivo a Firestore de forma constante
  Future<void> comenzarRastreoTiempoReal(String childId) async {
    bool servicioHabilitado;
    LocationPermission permiso;

    // 1. Verificar si el GPS físico del celular está encendido
    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      print('🔴 El GPS físico del dispositivo está apagado.');
      return;
    }

    // 2. Validar y solicitar los permisos al usuario en pantalla
    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        print('🔴 Permiso de GPS denegado por el usuario.');
        return;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      print('🔴 Permisos denegados permanentemente en los ajustes del sistema.');
      return;
    }

    // 3. Escucha cada cambio de posición del chip GPS y lo manda directo a Firestore
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, 
        distanceFilter: 10, // Se actualiza cada 10 metros
      ),
    ).listen((Position position) async {
      print('📍 Nueva ubicación detectada: ${position.latitude}, ${position.longitude}');
      
      await _db.collection('children').doc(childId).set({
        'position': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('💾 Ubicación sincronizada con éxito en Firestore');
    });
  }
}