import 'package:cloud_firestore/cloud_firestore.dart';

class FocusSession {
  final String id;
  final int secondsSpend;
  final String tag;
  final DateTime startTime;

  FocusSession({
    required this.id,
    required this.secondsSpend,
    required this.tag,
    required this.startTime,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'secondsSpend': secondsSpend,
      'tag': tag,
      'startTime': Timestamp.fromDate(startTime),
    };
  }
}