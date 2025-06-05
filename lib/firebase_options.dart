
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
    apiKey: 'AIzaSyBiaSDRc8tprcpIpKYlJKoypLR_J0sT4oM',
    appId: '1:480439870320:web:68b992be9d739ebf98a5b5',
    messagingSenderId: '480439870320',
    projectId: 'joinus-2e386',
    authDomain: 'joinus-2e386.firebaseapp.com',
    storageBucket: 'joinus-2e386.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAmIzy2jKexzMd6sP88kuN3Drno0eLrvfo',
    appId: '1:480439870320:ios:8d367f4c326a5adf98a5b5',
    messagingSenderId: '480439870320',
    projectId: 'joinus-2e386',
    storageBucket: 'joinus-2e386.firebasestorage.app',
    iosBundleId: 'com.example.joinus',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBiaSDRc8tprcpIpKYlJKoypLR_J0sT4oM',
    appId: '1:480439870320:web:cbde7c2cf71e779398a5b5',
    messagingSenderId: '480439870320',
    projectId: 'joinus-2e386',
    authDomain: 'joinus-2e386.firebaseapp.com',
    storageBucket: 'joinus-2e386.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmIzy2jKexzMd6sP88kuN3Drno0eLrvfo',
    appId: '1:480439870320:ios:8d367f4c326a5adf98a5b5',
    messagingSenderId: '480439870320',
    projectId: 'joinus-2e386',
    storageBucket: 'joinus-2e386.firebasestorage.app',
    iosBundleId: 'com.example.joinus',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8Mxdt6bxX36LZftWHyAmxnZC1AIM2A_c',
    appId: '1:480439870320:android:bbdf2f109c9f4ac998a5b5',
    messagingSenderId: '480439870320',
    projectId: 'joinus-2e386',
    storageBucket: 'joinus-2e386.firebasestorage.app',
  );

}