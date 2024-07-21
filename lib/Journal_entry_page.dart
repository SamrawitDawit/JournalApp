import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal_app/edit_journal.dart';
import 'package:journal_app/models.dart';
import 'package:journal_app/service.dart';
class JournalEntryPage extends StatefulWidget {
  final JournalEntry entry;

  JournalEntryPage({required this.entry});

  @override
  _JournalEntryPageState createState() => _JournalEntryPageState();
}
class _JournalEntryPageState extends State<JournalEntryPage>{
  final FirestoreService _firestoreService = FirestoreService();
  final PasswordService _passwordService = PasswordService();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVerified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.entry.isPasswordProtected) {
        _showPasswordDialog();
      } else {
        setState(() {
          _isPasswordVerified = true;
        });
      }
    });

  }
  void _editEntry() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditJournal(entry: widget.entry)),
    ).then((_) {
      setState(() {

      });
    });
  }
  void _deleteEntry() async {
    await _firestoreService.deleteJournalEntry(widget.entry.id);
    Navigator.pop(context);
  }
  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter Password"),
        content: TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: "Password"),
          obscureText: true,
        ),
        actions: [
          TextButton(
            child: Text("Submit"),
            onPressed: () async {
              final storedPassword = await _passwordService.getPassword();
              if (storedPassword == _passwordController.text) {
                setState(() {
                  _isPasswordVerified = true;
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Incorrect Password!")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.entry.title),
          actions: [
            IconButton(
                onPressed: _isPasswordVerified ? _editEntry : null,
                icon: Icon(Icons.edit)),
            IconButton(
                onPressed: _isPasswordVerified ? _deleteEntry : null,
                icon: Icon(Icons.delete))
          ],
        ),

      body: _isPasswordVerified
        ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(widget.entry.date),
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(width: 30,),
                if (widget.entry.mood != null) Text(widget.entry.mood!, style: TextStyle(fontSize: 25),)],
            ),
            SizedBox(height: 16),
            Text(
              widget.entry.content,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16,),
            if (widget.entry.mediaUrl != null)
              Center(
                child: Image.network(
                  widget.entry.mediaUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,

                )
              )
          ],
        ),
      )
        : Center(
        child: Text("This entry is secured"),
      )
    );
  }
}

