import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'signup.dart';
import 'login.dart';
import 'homepage.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServeSphere',
      theme: ThemeData(primarySwatch: Colors.green), // Changed to green to match your app
      debugShowCheckedModeBanner: false,
      // Use StreamBuilder to handle authentication state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, go to home page
            return const Homepage();
          }

          // User is not logged in, go to login page
          return const LoginPage();
        },
      ),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const Homepage(),
        '/profile': (context) {
          // Safe way to get arguments without null check operator
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            return UserProfile(userData: {'userId': currentUser.uid});
          } else {
            // Fallback if user is not logged in
            return UserProfile(userData: {});
          }
        },
        '/leaderboard': (context) => const LeaderboardPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/messages': (context) => const MessagesPage(),
        '/events': (context) => const EventsPage(),
      },
    );
  }
}
