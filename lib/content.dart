import 'package:cloud_firestore/cloud_firestore.dart';

class Content {
  final String message;
  final Timestamp? timestamp;

  Content({
    required this.message,
    this.timestamp,
  });

  factory Content.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Content(
      message: data?['message'],
      timestamp: data?['timestamp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'timestamp': timestamp ?? Timestamp.now(),
    };
  }
}

contentsQuery(String userId) => FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('contents')
    .orderBy('timestamp', descending: true);
