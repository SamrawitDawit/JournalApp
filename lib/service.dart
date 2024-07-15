import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:journal_app/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadMedia(File file) async {
    final ref = _storage.ref().child('journal_media/${file.path.split('/').last}');
    final uploadTaask = ref.putFile(file);
    final snapshot = await uploadTaask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
  Future<void> addJournalEntry(JournalEntry entry) {
    return _db.collection('journal_entries').add(entry.toMap());
  }

  Future<void> addUser(User user) {
    return _db.collection("users").doc(user.id).set(user.toMap());
  }

  Future<User?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Stream<List<JournalEntry>> getJournalEntries(String userId) {
    return _db
        .collection('journal_entries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.id, doc.data()!))
          .toList();
    });
  }
Future<List<JournalEntry>> getJournalEntriesOnce(String userId) async{
    final snapshot = await _db
        .collection('journal_entries')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => JournalEntry.fromMap(doc.id, doc.data()!))
        .toList();
}
}
