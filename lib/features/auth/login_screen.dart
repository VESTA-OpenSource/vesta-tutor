import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesta_app/services/auth_service.dart';
import 'package:vesta_app/widgets/vesta_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Por favor, rellena todos los campos.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.login(email, password);
      
    } catch (e) {
      _showSnackbar("Error al iniciar sesión. Verifica tus credenciales.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              const SizedBox(height: 10),
              const Text(
                "¡Bienvenido!",
                style: TextStyle(fontSize: 22, fontFamily: "Arial", fontWeight: FontWeight.bold, color: Color(0xFF1A1D24)),
              ),
              const SizedBox(height: 5),
              const Text(
                "Inicia sesión rápido y seguro con tus cuentas.",
                style: TextStyle(fontSize: 12, color: Color(0xFF8A92A6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              
              _buildInputField(
                label: "Correo electrónico o número telefónico",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                label: "Contraseña",
                controller: passwordController,
                obscureText: true,
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () { /* Lógica de reset password si se implementa */ },
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: Color(0xFF2B5BDE), fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Botón Principal de Login
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1D24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Iniciar sesión", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              const Text("O inicia sesión con:", style: TextStyle(color: Color(0xFF8A92A6), fontSize: 12)),
              const SizedBox(height: 10),
              
              // Botones de inicio de sesión de redes sociales 
              _buildSocialButton("G   Google", Colors.white, const Color(0xFF1A1D24), hasBorder: true),
              _buildSocialButton("A   Apple", const Color(0xFF1A1D24), Colors.white),
              _buildSocialButton("M   Microsoft", Colors.white, const Color(0xFF1A1D24), hasBorder: true),
              
              const SizedBox(height: 10),
              // Link hacia Registro usando go_router
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text(
                  "¿Nuevo Usuario? Crea cuenta",
                  style: TextStyle(color: Color(0xFF2B5BDE), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para mantener limpios los inputs
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF495057), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFF1A1D24)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF0F2F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para los botones OAuth estáticos originales
  Widget _buildSocialButton(String text, Color bg, Color fg, {bool hasBorder = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: bg,
            side: hasBorder ? const BorderSide(color: Color(0xFF1A1D24)) : BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: () {
          },
          child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}