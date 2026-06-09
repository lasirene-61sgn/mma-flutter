import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mmp_official/firebase_options.dart';
import 'package:mmp_official/service/api/local_storage/shared_preference.dart';
import 'service/notification_service/notifiction_service.dart';
import 'service/route/route_name.dart';
import 'service/route/route_page.dart';
import 'service/network/network_provider.dart';
import 'service/network/network_overlay.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) return;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling background message: ${message.messageId}");
}
void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  // Handle Firebase initialization safely
  if (defaultTargetPlatform != TargetPlatform.iOS) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint("Firebase initialization failed: $e");
    }
  }

  await NotificationService.init();
  final prefs = SharedPreferencesHelper();
  await prefs.init();

  String? deviceToken = await NotificationService.getToken();
  if (deviceToken != null) {
    debugPrint("--------- DEVICE TOKEN: $deviceToken ---------");
    await prefs.setString("DToken", deviceToken);
  }
  runApp(
    const ProviderScope(
      child: MMPApp(),
    ),
  );
}

class MMPApp extends ConsumerWidget {
  const MMPApp({super.key});

  // MMP Brand Colors
  static const Color maroon = Color(0xFFB11342); // Primary Crimson/Magenta
  static const Color maroonLight = Color(0xFFD8285C);
  static const Color maroonDark = Color(0xFF3A1F36); // Dark Plum
  static const Color borderBrown = Color(0xFF3A1F36); // Dark Plum for borders
  static const Color cream = Color(0xFFFFFBF8);
  static const Color orange = Color(0xFFFF8C00);
  static const Color gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnectedAsync = ref.watch(networkStatusProvider);
    final isConnected = isConnectedAsync.maybeWhen(
      data: (value) => value,
      orElse: () => true,
    );
    return GetMaterialApp(
      title: 'Mel Milaap Parivaar',
      debugShowCheckedModeBanner: false,
      initialRoute: RouteName.splash,
      getPages: RoutePage.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: maroon,
          primary: maroon,
          secondary: orange,
          surface: cream,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: maroon,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: maroon,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: maroon, width: 2),
          ),
        ),
      ),
      builder: (context, child) {
        return Material(
          child: Stack(
            children: [
              child!,
              if (!isConnected) const NetworkOverlay(),
            ],
          ),
        );
      },
    );
  }
}


