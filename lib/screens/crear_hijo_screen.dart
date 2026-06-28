import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CrearHijoScreen extends StatefulWidget {
  const CrearHijoScreen({super.key});

  @override
  _CrearHijoScreenState createState() => _CrearHijoScreenState();
}

class _CrearHijoScreenState extends State<CrearHijoScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    // Usamos PopScope para capturar el botón físico "atrás" del teléfono
    return PopScope(
      canPop: false, // Bloqueamos el comportamiento nativo
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home'); // Forzamos la redirección al home
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Registrar Nuevo Hijo"),
          // Reemplazamos la flecha automática por una manual para controlar el evento
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre del niño/a",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/home'), // Redirección absoluta
                child: const Text("Cancelar"),
              ),
              const SizedBox(height: 20),
              _cargando 
                ? const CircularProgressIndicator() 
                : ElevatedButton(
                    onPressed: () async {
                      if (_nombreController.text.isNotEmpty) {
                        setState(() => _cargando = true);
                        await _dbService.crearNuevoHijo(_nombreController.text);
                        if (mounted) {
                          setState(() => _cargando = false);
                          // Redirección absoluta tras completar la acción
                          context.go('/home');
                        }
                      }
                    },
                    child: const Text("Generar código y registrar"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}