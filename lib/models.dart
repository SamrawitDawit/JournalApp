import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String name;

  User({required this.id, required this.name});

  Map<String, dynamic> toMap(){
    return{
      'name': name
    };
  }
  factory User.fromMap(String id, Map<String, dynamic> map){
    return User(
      id: id,
      name: map['name']
    );
  }
}
class JournalEntry{
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime date;

  JournalEntry({required this.id, required this.userId,  required this.title, required this.content, required this.date});

  Map<String, dynamic> toMap(){
    return{
      'userId': userId,
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
    };
  }
  factory JournalEntry.fromMap(String id, Map<String, dynamic> map){
    return JournalEntry(
        id: id,
        userId: map['userId'],
        title: map['title'],
        content: map['content'],
        date: (map['date'] as Timestamp).toDate(),
    );
  }
}
