import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesta_app/services/auth_service.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final countryController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage; 
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    countryController.dispose();
    super.dispose();
  }
  Future<void> _handleRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = "Por favor, introduce un correo electrónico válido.";
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _errorMessage = "La contraseña debe tener al menos 6 caracteres.";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await authService.register(email, password, username);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), ''); 
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text("← Iniciar sesión", style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Regístrese en Vesta",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 25),
              _buildInputField(label: "Correo electrónico", controller: emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildInputField(label: "Contraseña", controller: passwordController, obscureText: true),
              const SizedBox(height: 15),
              _buildInputField(label: "Nombre de usuario", controller: usernameController),
              const SizedBox(height: 15),
              _buildInputField(label: "Tu país / región", controller: countryController),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE03131), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Registrarse", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE03131).withOpacity(0.2),
                    border: Border.all(color: const Color(0xFFE03131)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Error: $_errorMessage",
                    style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFA4A9B3), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller, 
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF222630), 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}