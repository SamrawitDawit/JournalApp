import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:journal_app/auth.dart';
import 'package:journal_app/edit_profile.dart';
import 'package:journal_app/models.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userModel;
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }
  Future<void> _fetchUserDetails() async {
    final user = _auth.currentUser;
    if(user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userModel = UserModel.fromMap(user.uid, userDoc.data()!);
        _profilePhotoUrl = user.photoURL;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _userModel == null ? Center(child: CircularProgressIndicator(),):
          Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePhotoUrl != null ? NetworkImage(_profilePhotoUrl!):AssetImage('assets/default_profile.jpg'),
                  ),
                  SizedBox(height: 16,),
                  Text(
                    _userModel!.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    _auth.currentUser!.email!.split('@')[0],
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16,),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfilePage()));
                      },
                      child: Text("Edit Profile")),
                  SizedBox(height: 15,),
                  ElevatedButton(
                      onPressed: () {
                        _auth.signOut();
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> AuthScreen()));
                      },
                      child: Text("Logout"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[100]),)
                ],


            ),
          )
    );
  }
}
