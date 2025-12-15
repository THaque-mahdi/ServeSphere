import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // ---------------- VALIDATION ----------------
  void _validateAndLogin() {
    if (_emailController.text.trim().isEmpty) {
      _showMessage("Email is required");
      return;
    }

    if (!_emailController.text.contains("@")) {
      _showMessage("Enter a valid email");
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showMessage("Password is required");
      return;
    }

    _loginAdmin();
  }

  // ---------------- LOGIN LOGIC ----------------
  Future<void> _loginAdmin() async {
    setState(() => _isLoading = true);

    try {
      // 🔐 Firebase Auth login
      UserCredential credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = credential.user;

      if (user == null) {
        _showMessage("Login failed");
        return;
      }

      // 🔎 Check admin role from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!snapshot.exists) {
        await FirebaseAuth.instance.signOut();
        _showMessage("Admin record not found");
        return;
      }

      Map<String, dynamic> data =
      snapshot.data() as Map<String, dynamic>;

      if (data['role'] == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        await FirebaseAuth.instance.signOut();
        _showMessage("You are not authorized as admin");
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Authentication error");
    } catch (e) {
      _showMessage("Error: $e");
      debugPrint("ADMIN LOGIN ERROR: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- MESSAGE ----------------
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.black,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Admin Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text("Login as Admin"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
