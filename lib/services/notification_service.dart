import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 📦 El motor nativo para pintar globos en Android
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 🚀 Inicializa y captura el token exclusivo de tu Xiaomi + Configura Alertas Locales
  Future<void> inicializarNotificaciones() async {
    // 1. Solicitar permisos nativos a Android
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🟢 Permiso de notificaciones concedido en el Xiaomi');
      
      String? token = await _fcm.getToken();
      if (token != null) {
        print('🔑 FCM Token de tu Xiaomi: $token');
        await _guardarTokenEnFirestore(token);
      }
    } else {
      print('🔴 El usuario bloqueó o denegó los permisos de notificación');
    }

    // 2. Inicializar los ajustes del canal nativo en el dispositivo
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);

    // 3. Crear el "Canal de Alerta Máxima" indispensable para saltarse restricciones de MIUI (Xiaomi)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'vesta_critical_alerts', // ID del canal
      'Alertas Críticas Vesta', // Nombre visible
      description: 'Canal destinado a reportar evasiones de seguridad inmediatas.',
      importance: Importance.max, // Fuerza el pop-up flotante en pantalla
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Escucha en primer plano (Foreground) mientras tienes la app abierta
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Mensaje recibido en Foreground: ${message.notification?.title}');
    });
  }

  // 🛡️ Sincroniza el token en el documento del Tutor
  Future<void> _guardarTokenEnFirestore(String token) async {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set({
        'fcmToken': token,
        'lastUpdateToken': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('💾 Sincronización exitosa en la colección "users"');
    }
  }

  // 🔥 EL DISPARADOR LOCAL: Esta función levanta el globo sin usar servidores externos
  Future<void> mostrarNotificacionInmediata({
    required String titulo, 
    required String subtitulo, 
    required String tipo
  }) async {
    
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'vesta_critical_alerts',
      'Alertas Críticas Vesta',
      importance: Importance.max,
      priority: Priority.high,
      color: tipo == 'critical' ? const Color(0xFFE03131) : const Color(0xFFFCC419),
      playSound: true,
      enableLights: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecond, // ID dinámico para que no se pisen entre sí
      '🚨 VESTA: $titulo',
      subtitulo,
      platformChannelSpecifics,
    );
  }
}