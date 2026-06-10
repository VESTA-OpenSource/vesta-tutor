import 'package:flutter/material.dart';

void main() {
  runApp(const VestaApp());
}

class VestaApp extends StatelessWidget {
  const VestaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VESTA Control Parental',
      debugShowCheckedModeBanner: false, // Quita la etiqueta fea de "Debug"
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1D24), // Gris oscuro de VESTA
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER CON ESCUDO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield, size: 50, color: Color(0xFF143379)),
                  const SizedBox(width: 10),
                  const Text(
                    'VESTA',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '¡Bienvenido!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // --- INPUT DE CORREO ---
              const Text('Correo electrónico', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF222630),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  hintText: 'ejemplo@correo.com',
                  hintStyle: const TextStyle(color: Colors.white38),
                ),
              ),
              const SizedBox(height: 15),

              // --- INPUT DE CONTRASEÑA ---
              const Text('Contraseña', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 5),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF222630),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: Colors.white38),
                ),
              ),
              const SizedBox(height: 25),

              // --- BOTÓN INICIAR SESIÓN ---
              ElevatedButton(
                onPressed: () {
                  print("Intentando iniciar sesión en VESTA...");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE03131), // Rojo Vesta
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Iniciar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}