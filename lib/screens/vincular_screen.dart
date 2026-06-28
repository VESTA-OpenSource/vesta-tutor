import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VincularScreen extends StatefulWidget {
  const VincularScreen({super.key});

  @override
  State<VincularScreen> createState() => _VincularScreenState();
}

class _VincularScreenState extends State<VincularScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _vincular() async {
    String codigo = _codeController.text.trim().toUpperCase();
    if (codigo.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Buscamos en todas las colecciones 'hijos' de todos los usuarios usando CollectionGroup
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('hijos')
          .where('pairingCode', isEqualTo: codigo)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;

        // Guardamos el ID del hijo en SharedPreferences para uso local (Background Service)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('childId', doc.id);

        // Actualizamos a 'vinculado'
        await doc.reference.update({'status': 'vinculado'});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Vinculado con éxito!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código no encontrado')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vinculación Vesta")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController, 
              decoration: const InputDecoration(
                labelText: 'Ingresa el código del Tutor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _vincular, 
                  child: const Text('Vincular Dispositivo'),
                ),
          ],
        ),
      ),
    );
  }
}