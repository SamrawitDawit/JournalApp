import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:journal_app/models.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadMedia(File file) async {
    final ref = _storage.ref().child('journal_media/${file.path.split('/').last}');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
  Future<void> addJournalEntry(JournalEntry entry) async{
    await _db.collection('journal_entries').add(entry.toMap());
  }
  Future<void> updateJournalEntry(JournalEntry entry) async {
    await _db.collection('journal_entries').doc(entry.id).update(entry.toMap());
  }
  Future<void> deleteJournalEntry(String entryId) async {
    await _db.collection('journal_entries').doc(entryId).delete();
  }
  Future<void> addUser(UserModel user) {
    return _db.collection("users").doc(user.id).set(user.toMap());
  }
  Future<bool> isUsernameAvailable(String username) async {
    final result = await _db.collection('users').where('name', isEqualTo: username).get();
    return result.docs.isEmpty;
  }
  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Stream<List<JournalEntry>> getJournalEntries(String userId) {
    return _db
        .collection('journal_entries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final entry = JournalEntry.fromMap(doc.id, doc.data()!);
        return entry;
      })
          .toList();
    });
  }
Future<List<JournalEntry>> getJournalEntriesOnce(String userId) async{
    final snapshot = await _db
        .collection('journal_entries')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) {
        final entry = JournalEntry.fromMap(doc.id, doc.data()!);
        return entry;
    }).toList();
  }
}
class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService(this.flutterLocalNotificationsPlugin) {
    tz.initializeTimeZones();
  }

  Future<void> scheduleDailyNotifications() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Morning Journal Reminder',
      'Don\'t forget to write your journal entry for the morning!',
      _nextInstanceOfTime(8, 0),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Night Journal Reminder',
      'Don\'t forget to write your journal entry for the night!',
      _nextInstanceOfTime(20, 0), // 8:00 PM
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}


class PasswordService {
  final _storage = FlutterSecureStorage();

  Future<void> setPassword(String password) async {
    await _storage.write(key: 'journal_password', value: password);
  }
  Future<String?> getPassword() async {
    return await _storage.read(key:'journal_password');
  }

  Future<void> clearPassword() async {
    await _storage.delete(key: 'journal_password');
  }
}