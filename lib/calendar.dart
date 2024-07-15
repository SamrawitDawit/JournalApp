import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journal_app/models.dart';
import 'package:journal_app/service.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<DateTime, List<JournalEntry>> _journalEntries = {};
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _fetchJournalEntries();
  }

  Future<void> _fetchJournalEntries() async {
    final user = _auth.currentUser;
    if (user != null) {
      final entries = await _firestoreService.getJournalEntriesOnce(user.uid);
      print("Journal entries fetched: $entries");
      setState(() {
        _journalEntries = _groupEntriesByDate(entries);
        _streak = _calculateStreak(entries);
      });
    }
  }

  Map<DateTime, List<JournalEntry>> _groupEntriesByDate(List<JournalEntry> entries) {
    Map<DateTime, List<JournalEntry>> data = {};
    for (var entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (data[date] == null) {
        data[date] = [];
      }
      data[date]!.add(entry);
    }
    return data;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) {
              return _journalEntries[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Current Streak: $_streak ${_streak == 1 ? 'day' : 'days'}", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
