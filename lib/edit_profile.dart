import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Memoire/auth.dart';
import 'package:Memoire/models.dart';
import 'package:Memoire/service.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PasswordService _passwordService = PasswordService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _journalPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  UserModel? _userModel;
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchProfilePhotoUrl();
  }

  Future<void> _fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userModel = UserModel.fromMap(user.uid, userDoc.data()!);
        _nameController.text = _userModel!.name;
      });
    }
  }

  Future<void> _fetchProfilePhotoUrl() async {
    final user = _auth.currentUser;
    setState(() {
      _profilePhotoUrl = user!.photoURL;
    });
  }

  Future<void> _updateProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final user = _auth.currentUser;
      if (user != null) {
        final filePath = 'profile_photos/${user.uid}.jpg';
        final storageRef = _storage.ref().child(filePath);
        final uploadTask = storageRef.putFile(File(pickedFile.path));

        final snapshot = await uploadTask.whenComplete(() => null);
        final photoURL = await snapshot.ref.getDownloadURL();

        await user.updatePhotoURL(photoURL);
        setState(() {
          _profilePhotoUrl = photoURL;
        });
      }
    }
  }

  Future<void> _authenticateAndEdit() async {
    final user = _auth.currentUser;
    if (user != null) {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      try {
        await user.reauthenticateWithCredential(cred);
        await _updateProfileDetails();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incorrect login password")),
        );
      }
    }
  }

  Future<void> _updateProfileDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      if (_nameController.text != _userModel!.name) {
        _userModel = UserModel(id: _userModel!.id, name: _nameController.text);
        await _firestore.collection('users').doc(user.uid).update(_userModel!.toMap());
      }
      await _passwordService.setPassword(_journalPasswordController.text);
      await user.reload();
      _fetchUserDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated")),
      );
    }
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter your login password"),
        content: TextField(
          controller: _currentPasswordController,
          decoration: InputDecoration(labelText: "login Password"),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _authenticateAndEdit();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit your profile'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () => {
                      _auth.signOut(),
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthScreen()),
                      ),
                    },
                  ),
                  TextButton(
                    onPressed: () => {
                      _auth.signOut(),
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthScreen()),
                      ),
                    },
                    child: Text("Log out"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profilePhotoUrl != null
                            ? NetworkImage(_profilePhotoUrl!)
                            : AssetImage('assets/default_profile.jpg') as ImageProvider,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updateProfilePhoto,
                        child: Text("Change Profile Photo"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(labelText: "Name"),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _journalPasswordController,
                              decoration: InputDecoration(labelText: "Journal Lock Password"),
                              obscureText: true,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _showPasswordDialog,
                              child: Text("Edit Profile"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[100],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
