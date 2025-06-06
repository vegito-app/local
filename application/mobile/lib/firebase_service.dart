import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

extension FirebaseAuthEmulatorCheck on FirebaseAuth {
  bool get isEmulator => app.options.apiKey == 'fake-api-key';
}

class FirebaseService {
  static Future<void> init() async {
    try {
      await _initializeFirebase();
    } catch (e) {
      throw Exception('Firebase initialization error: $e');
    }
  }

  static Future<void> _initializeFirebase() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    await Firebase.initializeApp();
    await _initializeMessaging();
    await FirebaseAuth.instance.signOut();

    if (!kReleaseMode && !FirebaseAuth.instance.isEmulator) {
      await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
    }

    // Utilisation de l’émulateur Storage en développement
    if (!kReleaseMode) {
      await FirebaseStorage.instance.useStorageEmulator('10.0.2.2', 9199);
    }
  }

  static Future<void> _initializeMessaging() async {
    // Notification setup
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Demander la permission (iOS)
    await messaging.requestPermission();

    // Obtenir le token FCM
    final token = await messaging.getToken();
    print('FCM Token: $token');

    // Écoute des messages reçus en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message reçu : ${message.notification?.title}');
    });
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel_id',
            'Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}
