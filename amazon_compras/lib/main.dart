import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/address_provider.dart';

import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/pre_login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/cart/checkout_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/support_chat_screen.dart';
import 'services/seed_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🌱 Autopoblar la base de datos de productos si está vacía
  await SeedService.seedDatabaseIfEmpty();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Amazon Compras',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFFF5F1E8),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F3A5F),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/wrapper': (context) => const AuthWrapper(),
          '/pre-login': (context) => const PreLoginScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin': (context) => const AdminPanelScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/support': (context) => const SupportChatScreen(),
        },
      ),
    );
  }
}