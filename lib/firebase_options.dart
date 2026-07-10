import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run `flutterfire configure` to generate them.',
        );
    }
  }
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNSUxyuPsOBSs_zjIVUDW1C9u_5M5oabY',
    appId: '1:708739655769:android:3b2c317df6ac0ddfede948',
    messagingSenderId: '708739655769',
    projectId: 'timer-4624c',
    storageBucket: 'timer-4624c.firebasestorage.app',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE_OUTPUT',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE_OUTPUT',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE_OUTPUT',
    projectId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE_OUTPUT',
    storageBucket: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE_OUTPUT',
    authDomain: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE_OUTPUT',
  );
}
