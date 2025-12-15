import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'signup.dart';
import 'login.dart';
import 'homepage.dart';
import 'admin_dashboard.dart';
import 'userprofile.dart';
import 'leaderboard.dart';
import 'notification.dart';
import 'message.dart';
import 'event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Replace this with your real admin UID
const String ADMIN_UID = "YOUR_ADMIN_UID";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServeSphere',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,

      // Auth state stream
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User logged in
          if (snapshot.hasData && snapshot.data != null) {
            final currentUser = snapshot.data!;

            // Navigate admin to Admin Dashboard
            if (currentUser.uid == ADMIN_UID) {
              return AdminDashboard();
            }

            // Normal user goes to Homepage
            return const Homepage();
          }

          // User not logged in
          return const LoginPage();
        },
      ),

      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const Homepage(),
        '/profile': (context) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            return UserProfile(userData: {'userId': currentUser.uid});
          } else {
            return UserProfile(userData: {});
          }
        },
        '/leaderboard': (context) => const LeaderboardPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/messages': (context) => const MessagesPage(),
        '/events': (context) => const EventsPage(),
        '/admin': (context) => AdminDashboard(),
      },
    );
  }
}
