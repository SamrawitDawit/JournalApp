import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Memoire/models.dart';
import 'package:Memoire/service.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final user = FirebaseAuth.instance.currentUser!;
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
        print("Journal entries grouped by date: $_journalEntries");
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

  Widget _buildEventMarker(DateTime date, List events) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      width: 20.0,
      height: 20.0,
      child: Icon(
        Icons.check,
        color: Colors.green,
        size: 14.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                final events = _journalEntries[day] ?? [];
                print("Events for $day: $events");
                return events;
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomCenter,
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return _buildEventMarker(date, events);
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Current Streak: $_streak ${_streak == 1 ? 'day' : 'days'}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
