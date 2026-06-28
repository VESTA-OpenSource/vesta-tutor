import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- REGISTRO Y LOGIN ---

  Future<UserCredential> register(String email, String password, String username) async {
    try {
      final existingUser = await _db.collection('users')
          .where('username_lower', isEqualTo: username.toLowerCase())
          .get();
      
      if (existingUser.docs.isNotEmpty) {
        throw Exception('El nombre de usuario ya está en uso.');
      }

      UserCredential uc = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      await _db.collection('users').doc(uc.user!.uid).set({
        'uid': uc.user!.uid,
        'email': email,
        'username': username, 
        'username_lower': username.toLowerCase(),
        'role': 'tutor',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return uc;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  // --- BÚSQUEDA DE IDENTIFICADOR ---

  Future<String?> getEmailByUsername(String username) async {
    final query = await _db.collection('users')
        .where('username_lower', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return query.docs.first.data()['email'];
    }
    return null;
  }

  // --- LOGIN SOCIAL ---

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) return false;
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    // Pendiente de implementar según tu configuración de Apple
    return false;
  }

  Future<bool> signInWithGitHub() async {
    try {
      // Requiere la configuración de GitHub Auth en Firebase Console
      UserCredential uc = await _auth.signInWithProvider(GithubAuthProvider());
      return uc.user != null;
    } catch (e) {
      return false;
    }
  }

  // --- RECUPERACIÓN ---

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  // --- CIERRE ---

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  String _handleAuthError(String code) {
    switch (code) {
      case 'invalid-credential': return 'Correo o contraseña incorrectos.';
      case 'user-not-found': return 'No existe una cuenta con este correo.';
      case 'email-already-in-use': return 'Este correo ya está registrado.';
      default: return 'Error de autenticación ($code).';
    }
  }
}