import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Memoire/models.dart';
import 'package:Memoire/service.dart';

class AddJournal extends StatefulWidget {
  @override
  _AddJournalState createState() => _AddJournalState();
}

class _AddJournalState extends State<AddJournal> {
  final FirestoreService _firestoreService = FirestoreService();
  final PasswordService _passwordService = PasswordService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedMood;
  File? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPasswordProtected = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Text("No user Logged in");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Journal Entry"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a title";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            // labelText: "Content",
                          ),
                          maxLines: 15,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter content";
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.perm_media),
                        onPressed: () async {
                          final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _mediaFile = File(pickedFile.path);
                            });
                          }
                        },
                      )],
                  ),
                if (_mediaFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Image.file(
                      _mediaFile!,
                      height: 200,
                      width: 200,
                    ),
                  ),
                SizedBox(height: 16),
                Text(
                  "How are you feeling today?",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodButton("😊", "happy"),
                    _buildMoodButton("🤗", "grateful"),
                    _buildMoodButton("😐", "neutral"),
                    _buildMoodButton("😔", "sad"),
                    _buildMoodButton("😟", "worried"),
                    _buildMoodButton("😠", "angry"),
                  ],
                ),
                SizedBox(height: 24),
                SwitchListTile(
                  title: Text("Password Protect Entry"),
                  value: _isPasswordProtected,
                  onChanged: (bool value) {
                    setState(() {
                      _isPasswordProtected = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String? mediaUrl;
                      if (_mediaFile != null) {
                        mediaUrl = await _firestoreService.uploadMedia(_mediaFile!);
                      }
                      final entry = JournalEntry(
                        id: '',
                        userId: user.uid,
                        title: _titleController.text,
                        content: _contentController.text,
                        date: DateTime.now(),
                        mood: _selectedMood,
                        mediaUrl: mediaUrl,
                        isPasswordProtected: _isPasswordProtected,
                      );
                      await _firestoreService.addJournalEntry(entry);
                      if (_isPasswordProtected) {
                        await _passwordService.setPassword(_passwordController.text);
                      }
                      _titleController.clear();
                      _contentController.clear();
                      setState(() {
                        _selectedMood = null;
                        _mediaFile = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Journal entry added")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[100],
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Add Entry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton(String emoji, String mood) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = emoji;
        });
      },
      child: CircleAvatar(
        radius: 24,
        backgroundColor: _selectedMood == emoji ? Colors.blue : Colors.grey[400],
        child: Text(
          emoji,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
