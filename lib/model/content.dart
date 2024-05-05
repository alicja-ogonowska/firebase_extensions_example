import 'package:cloud_firestore/cloud_firestore.dart';

class Content {
  final String? imageUrl;
  final String? recordingUrl;
  final String? transcription;
  final Timestamp? timestamp;

  Content({
    required this.imageUrl,
    required this.recordingUrl,
    this.transcription,
    this.timestamp,
  });

  factory Content.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Content(
      imageUrl: data?['imageUrl'],
      recordingUrl: data?['recordingUrl'],
      transcription: data?['transcription'],
      timestamp: data?['timestamp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'recordingUrl': recordingUrl,
      'timestamp': timestamp ?? Timestamp.now(),
      'transcription': transcription,
    };
  }
}

contentsQuery(String userId) => FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('contents')
    .orderBy('timestamp', descending: true);
