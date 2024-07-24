import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Memoire/models.dart';
import 'package:Memoire/service.dart';

class EditJournal extends StatefulWidget {
  final JournalEntry entry;
  EditJournal({required this.entry});

  @override
  _EditJournalState createState() => _EditJournalState();
}
class _EditJournalState extends State<EditJournal> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();


  final _formKey = GlobalKey<FormState>();
  String? _selectedMood;
  File? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPasswordProtected = false;
  final PasswordService _passwordService = PasswordService();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.entry.title;
    _contentController.text = widget.entry.content;
    _selectedMood = widget.entry.mood;
    _isPasswordProtected = widget.entry.isPasswordProtected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Journal Entry"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 16),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                        SizedBox(height: 16,),
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
                              color: Colors.blueGrey[400],
                            ),
                          ],
                        ),

                        if (_mediaFile != null)
                          Image.file(
                            _mediaFile!,
                            height: 200,
                            width: 200,
                          ),
                        SizedBox(height: 16,),
                        Text(
                          "How are you feeling today?",
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8,),
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
                        SizedBox(height: 60,),
                        SwitchListTile(
                            title: Text("Password Protect Entry"),
                            value: _isPasswordProtected,
                            onChanged: (bool value){
                              setState(() {
                                _isPasswordProtected = value;
                              });
                            }
                        ),
                        SizedBox(height: 16,),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String? mediaUrl = widget.entry.mediaUrl;
                              if (_mediaFile != null) {
                                mediaUrl = await _firestoreService.uploadMedia(_mediaFile!);
                              }
                              final entry = JournalEntry(
                                id: widget.entry.id,
                                userId: widget.entry.userId,
                                title: _titleController.text,
                                content: _contentController.text,
                                date: widget.entry.date,
                                mood: _selectedMood,
                                mediaUrl: mediaUrl,
                                isPasswordProtected: _isPasswordProtected,
                              );
                              await _firestoreService.updateJournalEntry(entry);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Journal entry updated")),
                              );
                              Navigator.pop(context);
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
                          child: Text("Update Entry"),
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