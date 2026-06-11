import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
class AddChildScreen extends StatefulWidget {
  final Map<String, dynamic>? childData; 
  const AddChildScreen({super.key, this.childData}); 
  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}
class _AddChildScreenState extends State<AddChildScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false; 
  @override
  void initState() {
    super.initState();
    if (widget.childData != null) {
      _isEditing = true;
      _nameController.text = widget.childData!['nombre'] ?? '';
      _ageController.text = widget.childData!['edad']?.toString() ?? '';
    }
  }
  void _saveChild() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('hijos');
      if (_isEditing) {
        final hijoId = widget.childData!['id'];
        await collection.doc(hijoId).update({
          'nombre': _nameController.text.trim(),
          'edad': int.parse(_ageController.text.trim()),
        });
      } else {
        await collection.add({
          'nombre': _nameController.text.trim(),
          'edad': int.parse(_ageController.text.trim()),
          'fechaRegistro': Timestamp.now(),
        });
      }
      if (mounted) {
        context.go('/'); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Menor' : 'Registrar Menor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del niño/a'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveChild,
                    child: Text(_isEditing ? 'Actualizar Perfil' : 'Guardar Perfil'),
                  ),
          ],
        ),
      ),
    );
  }
}