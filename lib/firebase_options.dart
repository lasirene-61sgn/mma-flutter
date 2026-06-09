import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios; // Return placeholder for iOS
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBx-mk8C0Ru4WIPf6VI0sJMu_a70scfKTI',
    appId: '1:450152570522:android:bf831e97b0e27e91ea0923',
    messagingSenderId: '450152570522',
    projectId: 'sirohi-app',
    storageBucket: 'sirohi-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-ios-api-key',
    appId: 'placeholder-ios-app-id',
    messagingSenderId: 'placeholder-ios-sender-id',
    projectId: 'placeholder-ios-project-id',
    storageBucket: 'placeholder-ios-storage-bucket',
    iosBundleId: 'com.sirohi.ssjsc',
  );
}