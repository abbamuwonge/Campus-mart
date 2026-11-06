import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/category_service.dart';
import 'services/favorite_service.dart';
import 'services/item_service.dart';
import 'services/message_service.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';
import 'theme.dart';
import 'widgets/app_toast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final api = ApiClient();
  final auth = AuthProvider(AuthService(api), api);
  unawaited(auth.restore()); // the splash screen shows while the saved login is checked

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        Provider<ItemService>.value(value: ItemService(api)),
        Provider<CategoryService>.value(value: CategoryService(api)),
        Provider<FavoriteService>.value(value: FavoriteService(api)),
        Provider<OrderService>.value(value: OrderService(api)),
        Provider<MessageService>.value(value: MessageService(api)),
        Provider<UserService>.value(value: UserService(api)),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ],
      child: const CampusMartApp(),
    ),
  );
}

class CampusMartApp extends StatelessWidget {
  const CampusMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusMart',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      scaffoldMessengerKey: messengerKey,
      home: const AuthGate(),
    );
  }
}

/// Chooses the first screen from the login state, and switches automatically when it changes
/// (login, logout, or the server rejecting an expired token).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    return switch (status) {
      AuthStatus.unknown => const SplashScreen(),
      AuthStatus.authenticated => const MainShell(),
      AuthStatus.unauthenticated => const AuthScreen(),
    };
  }
}
