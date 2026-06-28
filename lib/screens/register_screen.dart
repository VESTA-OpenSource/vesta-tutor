import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesta_app/core/utils/validators.dart';
import 'package:vesta_app/services/auth_service.dart';
import 'package:vesta_app/widgets/vesta_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final username = userController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 1. Validación de parámetros estrictos
    if (!Validators.isValidUsername(username)) {
      _showSnackbar("Usuario: 6-20 caracteres (letras, números, '.', '_').");
      return;
    }
    if (!Validators.isValidEmail(email)) {
      _showSnackbar("Correo electrónico no válido.");
      return;
    }
    if (!Validators.isValidPassword(password)) {
      _showSnackbar("Contraseña insegura: requiere mayúscula, minúscula, número y símbolo.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.register(email, password, username);
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      _showSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const VestaHeader(isDark: false),
              const SizedBox(height: 25),
              const Text("Crea tu cuenta de Vesta", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildInputField("Nombre de usuario", userController, TextInputType.text),
              const SizedBox(height: 15),
              _buildInputField("Correo electrónico", emailController, TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildInputField("Contraseña", passwordController, TextInputType.text, obscureText: true),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1D24)),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) 
                    : const Text("Registrarse", style: TextStyle(color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("¿Ya tienes cuenta? Inicia sesión"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, TextInputType type, {bool obscureText = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF495057))),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: type,
        decoration: const InputDecoration(filled: true, fillColor: Color(0xFFF0F2F5), border: OutlineInputBorder(borderSide: BorderSide.none)),
      ),
    ]);
  }
}