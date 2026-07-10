import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/firebase_error_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/push_notification_service.dart';
import 'services/user_service.dart';
import 'strings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Bootstraps Firebase before showing the real app. Shows [SplashScreen]
/// while that init is in flight, since nothing else can safely run yet.
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initFuture = _initFirebase();

  Future<void> _initFirebase() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.init();
    await PushNotificationService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        }
        if (snapshot.hasError) {
          return FirebaseErrorScreen(
            error: snapshot.error!,
            onRetry: () => setState(() => _initFuture = _initFirebase()),
          );
        }
        return const ProviderScope(child: _AuthGate());
      },
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateChangesProvider);
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.value;
      if (user != null) _onSignedIn(ref, user);
    });
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: authState.when(
        loading: () => const SplashScreen(),
        error: (_, _) => const LoginScreen(),
        data: (user) => user == null ? const LoginScreen() : const MainShell(),
      ),
    );
  }
}

Future<void> _onSignedIn(WidgetRef ref, User user) async {
  try {
    await ref.read(userRepositoryProvider).ensureUserDoc(user);
    await PushNotificationService.instance.saveTokenForUser(user.uid);
  } catch (e) {
    debugPrint('Failed to set up profile/FCM token for ${user.uid}: $e');
  }
}
