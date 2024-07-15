import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal_app/Journal_entry_page.dart';
import 'package:journal_app/calendar.dart';
import 'package:journal_app/quote_service.dart';
import 'package:journal_app/service.dart';
import 'models.dart';


class Journals extends StatefulWidget {
  @override
  _JournalState createState() => _JournalState();
}
class _JournalState extends State<Journals>{

  final user = FirebaseAuth.instance.currentUser!;
  final CalendarPage _calendarInstance = CalendarPage();
  FirestoreService _firestoreService = FirestoreService();
  QuoteService _quoteService = QuoteService();
  String _userName = "";
  int _streak = 0;
  int _numEntries = 0;
  String _dailyQuote = "";



  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchStreak();
    _fetchNumberOfEntries();
    _fetchDailyQuote();
  }
  Future<void> _fetchDailyQuote() async{
    final quote = await _quoteService.getDailyQuote();
    setState(() {
      _dailyQuote = quote;
      print(_dailyQuote);
    });
  }
  int _calculateStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    // Sort entries by date in descending order
    entries.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime streakDate = DateTime(today.year, today.month, today.day);

    for (var entry in entries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);

      if (entryDate.isAtSameMomentAs(streakDate) || entryDate.isAtSameMomentAs(streakDate.subtract(Duration(days: 1)))) {
        streak++;
        streakDate = streakDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> _fetchStreak() async {
      final entries = await _firestoreService.getJournalEntriesOnce(user.uid);
      setState(() {
        _streak = _calculateStreak(entries);
      });
  }
  Future<void> _fetchUserName() async{
      final userModel = await _firestoreService.getUser(user.uid);
      setState(() {
        _userName = userModel?.name ?? '';
      });
  }
  Future<void> _fetchNumberOfEntries() async{
    final entries = await _firestoreService.getJournalEntriesOnce(user.uid);
    setState(() {
      _numEntries = entries.length;
    });

  }

  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null){
      return Text("No user logged in");
    }
    FirestoreService _firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Journals"),
      ),

     body: Column(
       children: [
         Text("Hello $_userName!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, )),
         SizedBox(height: 20,),
         Padding(
           padding: EdgeInsets.all(8.0),
           child: Column(
             children: [
               Container(

                 child: Text(_dailyQuote, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
                 padding: const EdgeInsets.all(16.0),
                 decoration: BoxDecoration(
                   color: Colors.blue.shade100,
                   borderRadius: BorderRadius.circular(12),
                 ),
               ),
               SizedBox(height: 20,),
               Row(
                  children: [
                    _buildDashboardContainer(context,
                        title: "Streak", value: "$_streak ${_streak == 1 ? 'day' : 'days'}"),
                    SizedBox(width: 8,),
                    _buildDashboardContainer(context,
                        title: "Entries", value: _numEntries.toString())
                  ],
                   ),
             ],
           )
           ),
         SizedBox(height: 20,),
         Expanded(child: StreamBuilder<List<JournalEntry>>(
           stream: _firestoreService.getJournalEntries(user.uid),
           builder: (context, snapshot){
             if (snapshot.connectionState == ConnectionState.waiting){
               return Center(child: CircularProgressIndicator(),);
             }
             if (snapshot.hasError){
               print("error: ${snapshot.error}");
               return Center(child: Text("error: ${snapshot.error}"));
             }
             if (!snapshot.hasData || snapshot.data!.isEmpty){
               return Center(child: Text("No journal entries yet"),);
             }
             final entries = snapshot.data!;
             return ListView.builder(
                 itemCount: entries.length,
                 itemBuilder: (context,index){
                   final entry = entries[index];
                   return GestureDetector(
                     onTap: (){
                       Navigator.push(
                         context, MaterialPageRoute(builder: (context) => JournalEntryPage(entry: entry),)
                       );
                     },
                     child: Card(
                      child: ListTile(
                        title: Text(entry.title),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormat('yyyy-MM-dd').format(entry.date)),
                            if (entry.mood != null)
                              Text(entry.mood!, style: TextStyle(fontSize: 24),)
                          ],
                        )

                   )));
                 });
           },
         )),
       ],
     )
     ,
    );

  }
}
Widget _buildDashboardContainer(BuildContext context,
  {required String title, required String value}){
  return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).unselectedWidgetColor,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 40,),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ));
}

