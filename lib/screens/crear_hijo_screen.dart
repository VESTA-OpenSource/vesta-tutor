import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CrearHijoScreen extends StatefulWidget {
  @override
  _CrearHijoScreenState createState() => _CrearHijoScreenState();
}

class _CrearHijoScreenState extends State<CrearHijoScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrar Nuevo Hijo")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: "Nombre del niño/a",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _cargando 
              ? CircularProgressIndicator() 
              : ElevatedButton(
                  onPressed: () async {
                    if (_nombreController.text.isNotEmpty) {
                      setState(() => _cargando = true);
                      await _dbService.crearNuevoHijo(_nombreController.text);
                      setState(() => _cargando = false);
                      Navigator.pop(context); // Regresa a la lista
                    }
                  },
                  child: Text("Generar código y registrar"),
                ),
          ],
        ),
      ),
    );
  }
}