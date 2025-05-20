import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'package:smartagri/screens/home_page.dart';
import 'package:smartagri/screens/login_page.dart';
import 'package:smartagri/screens/register_page.dart';
import 'package:smartagri/screens/disease_library_page.dart';
import 'package:smartagri/screens/weather_page.dart';
import 'package:smartagri/screens/city_search_page.dart';
import 'package:smartagri/screens/AIdd.dart';
import 'package:smartagri/screens/homeai.dart'; // <-- Ensure this file exists

// Services
import 'package:smartagri/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arecanut Helper',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      // Entry point
      home: const AuthWrapper(),

      // Named static routes
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/disease_library': (context) => DiseaseLibraryPage(),
        '/city_search': (context) => const CitySearchPage(),
        '/ai_home': (context) => const AIHome(),
        '/homeai': (context) => const HomeAI(),
      },

      // Handle dynamic routes like weather
      onGenerateRoute: (settings) {
        if (settings.name == '/weather') {
          final args = settings.arguments;

          if (args is Map<String, dynamic> && args['city'] is String) {
            return MaterialPageRoute(
              builder: (context) => WeatherPage(city: args['city']),
              settings: settings,
            );
          }

          return MaterialPageRoute(
            builder:
                (context) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(
                    child: Text('City name is required for weather.'),
                  ),
                ),
            settings: settings,
          );
        }

        // Unknown route fallback
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Page Not Found')),
                body: const Center(child: Text('404 - Page not found')),
              ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<bool>(
      future: authService.isSessionValid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData &&
            snapshot.data == true &&
            authService.currentUser != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
