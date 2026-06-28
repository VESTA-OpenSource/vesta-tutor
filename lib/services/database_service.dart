import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> crearNuevoHijo(String nombre, int edad, int colorValue) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("Usuario no autenticado");

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String codigo = List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();

    await _db.collection('users').doc(uid).collection('hijos').add({
      'nombre': nombre,
      'edad': edad,
      'color': colorValue, 
      'pairingCode': codigo, 
      'status': 'esperando_vinculacion',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> activarDispositivo(String codigo, String deviceId) async {
    return await _db.runTransaction((transaction) async {
      // 1. Buscamos el documento con el código proporcionado
      final snapshot = await _db.collectionGroup('hijos')
          .where('pairingCode', isEqualTo: codigo.toUpperCase())
          .where('status', isEqualTo: 'esperando_vinculacion')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("El código no es válido o ya ha sido utilizado.");
      }

      final docRef = snapshot.docs.first.reference;
      final tutorId = docRef.parent.parent?.id;

      if (tutorId == null) throw Exception("Error al identificar al tutor.");

      // 2. Actualizamos el estado del hijo
      transaction.update(docRef, {
        'status': 'vinculado',
        'deviceId': deviceId,
        'vinculadoAt': FieldValue.serverTimestamp(),
      });

      // 3. Registramos el dispositivo para el seguimiento
      transaction.set(_db.collection('devices').doc(deviceId), {
        'hijoId': docRef.id,
        'tutorId': tutorId,
        'lastUpdate': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    });
  }
}