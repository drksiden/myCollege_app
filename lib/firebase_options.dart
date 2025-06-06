// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC1dGgjrn9_RWpFIf5wjHsX2wkUdKOnZ80',
    appId: '1:361946186456:web:8e335684941d3bf8500dad',
    messagingSenderId: '361946186456',
    projectId: 'mycollegeapp-4f6ce',
    authDomain: 'mycollegeapp-4f6ce.firebaseapp.com',
    storageBucket: 'mycollegeapp-4f6ce.firebasestorage.app',
    measurementId: 'G-PW5MCGW993',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHe6dxcy7FTFd3Rryjj-waHSmyIy24kAg',
    appId: '1:361946186456:android:329c81216b92c044500dad',
    messagingSenderId: '361946186456',
    projectId: 'mycollegeapp-4f6ce',
    storageBucket: 'mycollegeapp-4f6ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDHTqYfgVkZua2dxDg39SRjQH87-QFpEiU',
    appId: '1:361946186456:ios:11f31b0e1f66198a500dad',
    messagingSenderId: '361946186456',
    projectId: 'mycollegeapp-4f6ce',
    storageBucket: 'mycollegeapp-4f6ce.firebasestorage.app',
    iosClientId: '361946186456-n6kkj8rvu7tnut90s58g4sn47i4cv6r5.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );
}
