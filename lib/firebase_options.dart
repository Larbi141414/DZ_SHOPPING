// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCIY6EusoCHw8wNW1Hl1fkfYCNjNpD2KLo',
    appId: '1:444866312695:android:c337ed4d499fad1ce096f2',
    messagingSenderId: '444866312695',
    projectId: 'ecommerce-bde6e',
    storageBucket: 'ecommerce-bde6e.firebasestorage.app',
  );
}
