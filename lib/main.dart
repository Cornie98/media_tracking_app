import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/search_page.dart';
import 'screens/log_page.dart';
import 'screens/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables first
  try {
    await dotenv.load(fileName: "assets/.env");
    print("Environment variables loaded successfully");
    print("FIREBASE_API_KEY: ${dotenv.env['FIREBASE_API_KEY']}");
    print("FIREBASE_PROJECT_ID: ${dotenv.env['FIREBASE_PROJECT_ID']}");
    print("FIREBASE_APP_ID_ANDROID: ${dotenv.env['FIREBASE_APP_ID_ANDROID']}");
    print("RAWG_API_KEY: ${dotenv.env['RAWG_API_KEY']}");
    print("TMDB_API_KEY: ${dotenv.env['TMDB_API_KEY']}");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  
  // Then initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  
  runApp(MediaTrackingApp());
}

class MediaTrackingApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelf\'d',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          print('Auth state: ${snapshot.connectionState}');
          print('Has data: ${snapshot.hasData}');
          print('User: ${snapshot.data}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Showing loading screen');
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            
            print('User is signed in, showing MainScreen');
            return MainScreen();
          } else {
            print('User is not signed in, showing LoginScreen');
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => MainScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    LogPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
