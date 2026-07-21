import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _orderChannel =
      AndroidNotificationChannel(
    'status_pesanan',
    'Status Pesanan',
    description:
        'Notifikasi perubahan status pesanan Lapar Manten Delivery',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    // Inisialisasi notifikasi lokal
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) {
        debugPrint(
          'Notifikasi ditekan. Payload: ${response.payload}',
        );
      },
    );

    // Membuat channel notifikasi Android
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      _orderChannel,
    );

    // Meminta izin notifikasi satu kali
    final NotificationSettings permission =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'IZIN NOTIFIKASI: ${permission.authorizationStatus}',
    );

    // Notifikasi ketika aplikasi sedang terbuka
    FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );

    // Ketika notifikasi ditekan dari background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint(
          'Notifikasi membuka aplikasi: ${message.data}',
        );
      },
    );

    // Ketika aplikasi dibuka dari kondisi tertutup
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        'Aplikasi dibuka dari notifikasi: '
        '${initialMessage.data}',
      );
    }

    // Mengambil dan menyimpan token FCM
    try {
      final String? token =
          await FirebaseMessaging.instance.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM TOKEN masih null.');
      } else {
        debugPrint(
          'FCM TOKEN BERHASIL DIPEROLEH.',
        );
        debugPrint('FCM TOKEN: $token');

        // Simpan token ke Supabase jika pelanggan sudah login
        await _registerTokenToSupabase(token);
      }
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('GAGAL MENGAMBIL FCM TOKEN');
      debugPrint('Kode Firebase: ${e.code}');
      debugPrint('Pesan Firebase: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
    } catch (e, stackTrace) {
      debugPrint('ERROR FCM LAINNYA: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    // Menyimpan ulang token apabila FCM memperbaruinya
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (String newToken) async {
        debugPrint(
          'FCM TOKEN DIPERBARUI: $newToken',
        );

        await _registerTokenToSupabase(newToken);
      },
      onError: (Object error) {
        debugPrint(
          'GAGAL MEMPERBARUI FCM TOKEN: $error',
        );
      },
    );
  }

  static Future<void> _showForegroundNotification(
    RemoteMessage message,
  ) async {
    final RemoteNotification? remoteNotification =
        message.notification;

    final String title =
        remoteNotification?.title ??
        message.data['title']?.toString() ??
        'Lapar Manten Delivery';

    final String body =
        remoteNotification?.body ??
        message.data['body']?.toString() ??
        'Ada pembaruan pada pesanan Anda.';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'status_pesanan',
      'Status Pesanan',
      channelDescription:
          'Notifikasi perubahan status pesanan '
          'Lapar Manten Delivery',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .remainder(100000),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: message.data['order_id']?.toString(),
    );
  }

  static Future<void> _registerTokenToSupabase(
    String token,
  ) async {
    try {
      final user =
          Supabase.instance.client.auth.currentUser;

      if (user == null) {
        debugPrint(
          'Token belum disimpan karena pelanggan belum login.',
        );
        return;
      }

      await Supabase.instance.client.rpc(
        'register_push_token',
        params: {
          'p_token': token,
        },
      );

      debugPrint(
        'FCM TOKEN BERHASIL DISIMPAN KE SUPABASE.',
      );
    } catch (e) {
      debugPrint(
        'GAGAL MENYIMPAN TOKEN KE SUPABASE: $e',
      );
    }
  }

  // Dipanggil setelah pelanggan berhasil login
  static Future<void> saveTokenToSupabase() async {
    try {
      final String? token =
          await FirebaseMessaging.instance.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM token masih kosong.');
        return;
      }

      await _registerTokenToSupabase(token);
    } catch (e) {
      debugPrint(
        'Gagal mengambil FCM token: $e',
      );
    }
  }

  // Dipanggil sebelum pelanggan logout
  static Future<void> removeTokenFromSupabase() async {
    try {
      final user =
          Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final String? token =
          await FirebaseMessaging.instance.getToken();

      if (token == null || token.isEmpty) return;

      await Supabase.instance.client.rpc(
        'unregister_push_token',
        params: {
          'p_token': token,
        },
      );

      debugPrint(
        'FCM TOKEN DIHAPUS DARI AKUN.',
      );
    } catch (e) {
      debugPrint(
        'Gagal menghapus FCM token: $e',
      );
    }
  }
}