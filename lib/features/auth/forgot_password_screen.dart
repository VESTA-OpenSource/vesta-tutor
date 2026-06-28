import 'package:flutter/material.dart';
import 'package:vesta_app/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    if (emailController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await authService.resetPassword(emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Se ha enviado un correo de recuperación.")),
        );
        Navigator.pop(context); // Regresar al Login
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo electrónico")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              child: _isLoading ? const CircularProgressIndicator() : const Text("Enviar correo"),
            ),
          ],
        ),
      ),
    );
  }
}