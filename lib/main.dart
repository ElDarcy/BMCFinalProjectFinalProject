import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:google_fonts/google_fonts.dart';


const kNeonAccent = Colors.greenAccent;
const kMetallicGray = Color(0xFF424242);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Supplements Store', 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black, 
          brightness: Brightness.dark, 
          primary: kNeonAccent, 
          onPrimary: Colors.black, 
          secondary: kMetallicGray, 
          onSecondary: Colors.white, 
          background: Colors.black, 
          onBackground: Colors.white, 
        ),
        textTheme: GoogleFonts.latoTextTheme(),
        scaffoldBackgroundColor: Colors.black, 
        appBarTheme: AppBarTheme(
          backgroundColor: kMetallicGray, 
          foregroundColor: Colors.white, 
          centerTitle: true,
          elevation: 4,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kNeonAccent, 
            foregroundColor: Colors.black, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kMetallicGray.withOpacity(0.5), 
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kMetallicGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kNeonAccent, width: 2), 
          ),
        ),
        cardTheme: CardThemeData(
          color: kMetallicGray.withOpacity(0.8), 
          elevation: 4,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/order-success': (context) => const OrderSuccessScreen(),
      },
      initialRoute: '/',
    );
  }
}