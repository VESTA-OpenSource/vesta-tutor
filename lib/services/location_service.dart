import 'package:cloud_firestore/cloud_firestore.dart';

class TutorLocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Este stream escucha en tiempo real la posición del hijo
  // Ruta: users/{tutorId}/hijos/{childId}
  Stream<Map<String, dynamic>?> obtenerUbicacionHijoStream(String tutorId, String childId) {
    return _db
        .collection('users')
        .doc(tutorId)
        .collection('hijos')
        .doc(childId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        // Retornamos el campo 'position' si existe y es del tipo correcto
        return data['position'] as Map<String, dynamic>?;
      }
      return null;
    });
  }
}