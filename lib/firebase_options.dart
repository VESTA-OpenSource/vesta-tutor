import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAMAvjrzQOz0DS678r-Qs7RcXXoTJ0IVSo',
    appId: '1:467514559504:web:efb16f0458dc2d8d510e95',
    messagingSenderId: '467514559504',
    projectId: 'vesta-opensource',
    authDomain: 'vesta-opensource.firebaseapp.com',
    storageBucket: 'vesta-opensource.firebasestorage.app',
    measurementId: 'G-K712NHX860',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCa2sVMDvHCDlO8c5C09PVy1GsgJWDw8pg',
    appId: '1:467514559504:android:455366584c00ac88510e95',
    messagingSenderId: '467514559504',
    projectId: 'vesta-opensource',
    storageBucket: 'vesta-opensource.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIKCVCNPmv-IW43PjwUoni601KMBZ5-Mc',
    appId: '1:467514559504:ios:f56fc51ba6bbd03b510e95',
    messagingSenderId: '467514559504',
    projectId: 'vesta-opensource',
    storageBucket: 'vesta-opensource.firebasestorage.app',
    iosBundleId: 'com.example.vestaApp',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAIKCVCNPmv-IW43PjwUoni601KMBZ5-Mc',
    appId: '1:467514559504:ios:f56fc51ba6bbd03b510e95',
    messagingSenderId: '467514559504',
    projectId: 'vesta-opensource',
    storageBucket: 'vesta-opensource.firebasestorage.app',
    iosBundleId: 'com.example.vestaApp',
  );
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAMAvjrzQOz0DS678r-Qs7RcXXoTJ0IVSo',
    appId: '1:467514559504:web:43dd404e1f3f69aa510e95',
    messagingSenderId: '467514559504',
    projectId: 'vesta-opensource',
    authDomain: 'vesta-opensource.firebaseapp.com',
    storageBucket: 'vesta-opensource.firebasestorage.app',
    measurementId: 'G-RSZM51TP00',
  );
}