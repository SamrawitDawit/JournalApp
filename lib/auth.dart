import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journal_app/main.dart';
import 'package:journal_app/pages.dart';
import 'package:journal_app/service.dart';
import 'models.dart' as entities;


class AuthScreen extends StatefulWidget{
  @override
  _AuthScreenState createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;

  Future<void> _signIn() async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text);
      NotificationService(flutterLocalNotificationsPlugin).scheduleDailyNotifications();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Pages()));

    }
    catch(e){
      print(e);
    }
  }
  Future<void> _signUp() async{
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text);
      final user = userCredential.user;
      if(user != null){
        final userModel = entities.User(
            id: user.uid,
            name: _nameController.text);

        await _firestoreService.addUser(userModel);
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Pages()));
    }

    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Sign up':'Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if(_isSignUp) TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name"),) ,
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email"),),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true,),
            ElevatedButton(onPressed: _isSignUp ? _signUp : _signIn, child: Text(_isSignUp ? "Sign up" : "Sign in")),
            TextButton(onPressed: (){
              setState(() {
                _isSignUp = !_isSignUp;
              }
              );
            }, child: Text(_isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")),
          ],
        ),
      ),
    );
  }
}

