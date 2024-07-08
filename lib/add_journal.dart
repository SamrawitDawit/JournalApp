import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journal_app/auth.dart';
import 'package:journal_app/models.dart';
import 'package:journal_app/service.dart';

class AddJournal extends StatefulWidget {
  @override
  _AddJournalState createState() => _AddJournalState();
}
class _AddJournalState extends State<AddJournal>{
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override

  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Text("No user Logged in");
    }
    return Scaffold(
      appBar: AppBar(title: Text("Journal App"),
        actions: [
          IconButton(onPressed:() async{
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
          },
              icon: Icon(Icons.logout))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              SizedBox(height: 16,),
              Padding(padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                          labelText: "Title",
                          // border: OutlineInputBorder()
                      ),
                      validator: (value){
                        if (value==null||value.isEmpty){
                          return "Please enter a title";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16,),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(labelText: "Content"),
                      maxLines: 15,
                      validator: (value){
                        if (value==null||value.isEmpty){
                          return "Please enter content";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16,),
                    ElevatedButton(
                        onPressed: () async{
                          if(_formKey.currentState!.validate()) {
                            final entry = JournalEntry(
                                id: '',
                                userId: user.uid,
                                title: _titleController.text,
                                content: _contentController.text,
                                date: DateTime.now());
                            await _firestoreService.addJournalEntry(entry);
                            _titleController.clear();
                            _contentController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Journal entry added"))
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                        ),
                        child: Text("Add Entry")
                    )
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