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
  final FirestoreService _firestoreService = FirestoreService();
  Map<DateTime, List<JournalEntry>> _journalEntries = {};
  int _streak = 0;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchJournalEntries();
  }

  Future<void> _fetchJournalEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final entries = await _firestoreService.getJournalEntriesOnce(user.uid);
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
    entries.sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime today = DateTime.now();
    DateTime streakDate = DateTime(today.year, today.month, today.day);
    Set<DateTime> countedDates = {};

    for (var entry in entries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (!countedDates.contains(entryDate)) {
        if (isSameDay(entryDate, streakDate) || isSameDay(entryDate, streakDate.subtract(Duration(days: 1)))) {
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

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year && day1.month == day2.month && day1.day == day2.day;
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
        color: Colors.white,
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
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                final events = _journalEntries[day] ?? [];
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
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
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
