import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin_login_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ---------------- USER LOGIN ----------------
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException("Login timeout"),
      );

      // Email verification check
      if (!userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email before login."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Navigate to user home
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No user found for this email.";
          break;
        case 'wrong-password':
          message = "Wrong password.";
          break;
        case 'invalid-email':
          message = "Invalid email.";
          break;
        case 'network-request-failed':
          message = "Network error. Try again.";
          break;
        default:
          message = "Login failed.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request timed out. Check internet."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // ---------------- INPUT DECORATION ----------------
  InputDecoration _inputDecoration(
      String label,
      IconData icon, {
        bool isPassword = false,
      }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: isPassword
          ? IconButton(
        icon: Icon(
          showPassword ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () => setState(() => showPassword = !showPassword),
      )
          : null,
      border: const OutlineInputBorder(),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: emailController,
                    decoration:
                    _inputDecoration("Email", Icons.email),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter email";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: _inputDecoration(
                      "Password",
                      Icons.lock,
                      isPassword: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter password";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // -------- USER LOGIN BUTTON --------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // -------- ADMIN LOGIN BUTTON --------
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text("Login as Admin"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AdminLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
