import 'package:flutter/material.dart';
import 'package:journal_app/add_journal.dart';
import 'package:journal_app/calendar.dart';
import 'package:journal_app/journals.dart';
import 'package:journal_app/main.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Journals(),
    AddJournal(),
    CalendarPage(),
  ];
  void _onTabTapped(int index){
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}


class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const CustomBottomNavigation({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Create"
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar'
        )
      ]);
  }
}
