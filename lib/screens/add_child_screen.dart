import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/database_service.dart';

class AddChildScreen extends StatefulWidget {
  final Map<String, dynamic>? childData;
  const AddChildScreen({super.key, this.childData});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  
  bool _isLoading = false;
  bool _isEditing = false;
  
  final List<Color> _avatarColors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
  int _selectedColorIndex = 0;

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor completa todos los campos')));
      return;
    }
    setState(() => _isLoading = true);
    
    try {
      await _dbService.crearNuevoHijo(
        _nameController.text.trim(),
        int.parse(_ageController.text.trim()),
        _avatarColors[_selectedColorIndex].value,
      );
      // Redirección segura tras guardar
      if (mounted) context.go('/');
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Perfil' : 'Nuevo Menor')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre del Menor')),
            TextField(controller: _ageController, decoration: const InputDecoration(labelText: 'Edad'), keyboardType: TextInputType.number),
            
            const SizedBox(height: 30),
            const Text("Selecciona un color para identificar su perfil:"),
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_avatarColors.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _avatarColors[index],
                      shape: BoxShape.circle,
                      border: _selectedColorIndex == index ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                  ),
                );
              }),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : ElevatedButton(
                          onPressed: _saveChild,
                          child: Text(_isEditing ? 'Actualizar Información' : 'Registrar Menor'),
                        ),
                  ),
                  const SizedBox(height: 10),
                  
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // Navegación segura para evitar GoError
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}