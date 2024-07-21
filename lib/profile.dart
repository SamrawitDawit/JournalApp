import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journal_app/service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final PasswordService _passwordService = PasswordService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _journalPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchJournalPassword();
  }

  Future<void> _fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userModel = await _firestoreService.getUser(user.uid);
      setState(() {
        _nameController.text = userModel?.name ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _fetchJournalPassword() async {
    final password = await _passwordService.getPassword();
    setState(() {
      _journalPasswordController.text = password ?? '';
    });
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
          SnackBar(content: Text("Authentication failed")),
        );
      }
    }
  }

  Future<void> _updateProfileDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(_nameController.text);
      await user.verifyBeforeUpdateEmail(_emailController.text);
      await user.updatePassword(_passwordController.text);
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
        title: Text("Enter current password"),
        content: TextField(
          controller: _currentPasswordController,
          decoration: InputDecoration(labelText: "Current Password"),
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
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "New Password"),
              obscureText: true,
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
            ),
          ],
        ),
      ),
    );
  }
}
