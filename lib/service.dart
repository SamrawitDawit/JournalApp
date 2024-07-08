import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journal_app/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      print('Journal entries: ${snapshot.docs.map((doc) => doc.data())}');
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
