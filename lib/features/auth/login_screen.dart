import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesta_app/core/utils/validators.dart';
import 'package:vesta_app/services/auth_service.dart';
import 'package:vesta_app/widgets/vesta_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showSnackbar("Por favor, rellena todos los campos.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String emailToUse = identifier;

      // Si no tiene formato de email, buscamos el email asociado al username exacto
      if (!Validators.isValidEmail(identifier)) {
        String? foundEmail = await authService.getEmailByUsername(identifier);
        
        if (foundEmail == null) {
          _showSnackbar("Usuario o correo no encontrado.");
          setState(() => _isLoading = false);
          return;
        }
        emailToUse = foundEmail;
      }

      await authService.login(emailToUse, password);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      _showSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);
    try {
      bool success = false;
      switch (provider) {
        case 'Google': success = await authService.signInWithGoogle(); break;
        case 'Apple': success = await authService.signInWithApple(); break;
        case 'GitHub': success = await authService.signInWithGitHub(); break;
      }

      if (success && mounted) context.go('/dashboard');
    } catch (e) {
      _showSnackbar("Error al iniciar con $provider.");
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
              const Text("¡Bienvenido!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1D24))),
              const SizedBox(height: 25),
              
              _buildInputField("Correo o Usuario", identifierController, TextInputType.text),
              const SizedBox(height: 15),
              _buildInputField("Contraseña", passwordController, TextInputType.text, obscureText: true),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Color(0xFF2B5BDE))),
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1D24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Iniciar sesión", style: TextStyle(color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 25),
              const Text("O inicia sesión con:", style: TextStyle(color: Color(0xFF8A92A6), fontSize: 12)),
              const SizedBox(height: 15),
              
              _buildSocialButton("Google", "assets/google.png", Colors.white, const Color(0xFF1A1D24), true, () => _handleSocialLogin('Google')),
              _buildSocialButton("Apple", "assets/apple.png", const Color(0xFF1A1D24), Colors.white, false, () => _handleSocialLogin('Apple')),
              _buildSocialButton("GitHub", "assets/github.png", Colors.white, const Color(0xFF1A1D24), true, () => _handleSocialLogin('GitHub')),
              
              TextButton(onPressed: () => context.push('/register'), child: const Text("¿Nuevo Usuario? Crea cuenta", style: TextStyle(color: Color(0xFF2B5BDE), fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, TextInputType type, {bool obscureText = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF495057), fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: type,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF0F2F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
        ),
      ),
    ]);
  }

  Widget _buildSocialButton(String text, String assetPath, Color bg, Color fg, bool hasBorder, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: bg,
            side: hasBorder ? const BorderSide(color: Color(0xFF1A1D24)) : BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
          ),
          onPressed: _isLoading ? null : onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, width: 20, height: 20),
              const SizedBox(width: 10),
              Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}