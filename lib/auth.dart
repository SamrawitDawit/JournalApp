import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Memoire/main.dart';
import 'package:Memoire/pages.dart';
import 'package:Memoire/service.dart';
import 'models.dart' as entities;

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;
  String _error = '';

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: "${_userNameController.text}@journalapp.com",
        password: _passwordController.text,
      );
      NotificationService(flutterLocalNotificationsPlugin).scheduleDailyNotifications();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Pages()));
    } catch (e) {
      setState(() {
        _error = 'Invalid username or password. Please try again.';
      });
    }
  }

  Future<void> _signUp() async {
    if (_userNameController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() {
        _error = 'Username and Name cannot be empty';
      });
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters long';
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: "${_userNameController.text}@journalapp.com",
        password: _passwordController.text,
      );
      final user = userCredential.user;
      if (user != null) {
        final userModel = entities.UserModel(
          id: user.uid,
          name: _nameController.text,
        );
        await _firestoreService.addUser(userModel);
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Pages()));
    } catch (e) {
      setState(() {
        _error = 'Failed to sign up. Please try again.';
        if (e is FirebaseAuthException) {
          _error = e.message ?? _error;
        } else if (e is FirebaseException) {
          _error = e.message ?? _error;
        }
        _error = _error.replaceAll('email address', 'Username');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUp ? 'Sign Up' : 'Log In',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    if (_isSignUp)
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(color: Colors.blueGrey),
                          filled: true,
                          fillColor: Colors.purple.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    if (_isSignUp)
                      SizedBox(height: 20),
                    TextField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        labelStyle: TextStyle(color: Colors.blueGrey),
                        filled: true,
                        fillColor: Colors.purple.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.blueGrey),
                        filled: true,
                        fillColor: Colors.purple.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    if (_error.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          _error,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSignUp ? _signUp : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        _isSignUp ? "Sign Up" : "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _error = '';
                        });
                      },
                      child: Text(
                        _isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
