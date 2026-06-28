import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // El motor nativo para pintar globos en Android
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Inicializa y captura el token
  Future<void> inicializarNotificaciones() async {
    // 1. Solicitar permisos nativos
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _guardarTokenEnFirestore(token);
      }
    }

    // 2. Inicializar los ajustes del canal nativo
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _localNotifications.initialize(initializationSettings);

    // 3. Crear el "Canal de Alerta Máxima" para saltarse restricciones de sistema (MIUI/EMUI)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'vesta_critical_alerts', 
      'Alertas Críticas Vesta',
      description: 'Canal destinado a reportar incidentes de seguridad inmediatos.',
      importance: Importance.max, // Fuerza el pop-up flotante
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Sincroniza el token en el documento del Tutor
  Future<void> _guardarTokenEnFirestore(String token) async {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set({
        'fcmToken': token,
        'lastUpdateToken': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // El disparador local: levanta el globo sin usar servidores externos
  Future<void> mostrarNotificacionInmediata({
    required String titulo, 
    required String subtitulo, 
    required String tipo
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'vesta_critical_alerts',
      'Alertas Críticas Vesta',
      importance: Importance.max,
      priority: Priority.high,
      color: tipo == 'critical' ? const Color(0xFFE03131) : const Color(0xFFFCC419),
      playSound: true,
      enableLights: true,
    );
    
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecond, 
      '🚨 VESTA: $titulo',
      subtitulo,
      platformChannelSpecifics,
    );
  }
}