import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VincularScreen extends StatefulWidget {
  @override
  _VincularScreenState createState() => _VincularScreenState();
}

class _VincularScreenState extends State<VincularScreen> {
  final _codeController = TextEditingController();

  Future<void> _vincular() async {
    String codigo = _codeController.text.trim().toUpperCase();
    
    // Buscamos en todas las colecciones 'hijos' de todos los usuarios
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup('hijos')
        .where('pairingCode', isEqualTo: codigo)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      // Guardamos el ID del hijo en el celular para que el LocationService lo use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('childId', doc.id);
      
      // Actualizamos a 'vinculado'
      await doc.reference.update({'status': 'vinculado'});
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Vinculado con éxito!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Código no encontrado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(controller: _codeController, decoration: InputDecoration(labelText: 'Ingresa el código del Tutor')),
          ElevatedButton(onPressed: _vincular, child: Text('Vincular Dispositivo')),
        ],
      ),
    );
  }
}