import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Memoire/edit_profile.dart';
import 'package:Memoire/quote_service.dart';
import 'package:Memoire/service.dart';
import 'models.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  FirestoreService _firestoreService = FirestoreService();
  QuoteService _quoteService = QuoteService();
  String _userName = "";
  int _streak = 0;
  int _numEntries = 0;
  String _dailyQuote = "";
  String? _profilePhotoURL;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchStreak();
    _fetchNumberOfEntries();
    _fetchDailyQuote();
    _fetchProfilePhotorUrl();
  }

  Future<void> _fetchDailyQuote() async {
    final quote = await _quoteService.getDailyQuote();
    setState(() {
      _dailyQuote = quote;
    });
  }

  int _calculateStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;
    entries.sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime today = DateTime.now();
    DateTime streakDate = DateTime(today.year, today.month, today.day);
    Set<DateTime> countedDates = {};

    for (var entry in entries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (!countedDates.contains(entryDate)) {
        if (entryDate.isAtSameMomentAs(streakDate) || entryDate.isAtSameMomentAs(streakDate.subtract(Duration(days: 1)))) {
          streak++;
          countedDates.add(entryDate);
          streakDate = streakDate.subtract(Duration(days: 1));
        } else {
          break;
        }
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

  Future<void> _fetchUserName() async {
    final userModel = await _firestoreService.getUser(user.uid);
    setState(() {
      _userName = userModel?.name ?? '';
    });
  }

  Future<void> _fetchNumberOfEntries() async {
    final entries = await _firestoreService.getJournalEntriesOnce(user.uid);
    setState(() {
      _numEntries = entries.length;
    });
  }

  Future<void> _fetchProfilePhotorUrl() async {
    setState(() {
      _profilePhotoURL = user.photoURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Memoire"),
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
            icon: CircleAvatar(
              backgroundImage: _profilePhotoURL != null
                  ? NetworkImage(_profilePhotoURL!)
                  : AssetImage('assets/default_profile.jpg') as ImageProvider,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children:[Center(
                  child: Image.asset(
                    'assets/home_page_img.jpg',
                    // width: 500,
                    fit: BoxFit.cover,
                  ),
                ),
                  SizedBox(height: 16),
                  Text(
                    "Welcome back, $_userName!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
              ]),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDashboardContainer(
                    context,
                    title: "Streak",
                    value: "$_streak ${_streak == 1 ? 'day' : 'days'}",
                  ),
                  SizedBox(width: 8),
                  _buildDashboardContainer(
                    context,
                    title: "Entries",
                    value: _numEntries.toString(),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Text(
                "Daily Quote",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _dailyQuote,
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContainer(BuildContext context, {required String title, required String value}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: Colors.blueAccent, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
