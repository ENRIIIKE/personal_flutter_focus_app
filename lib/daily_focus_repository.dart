// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Add uuid package to pubspec.yaml for unique IDs
import 'package:flutter_application_1/focus_session.dart';

class DailyFocusRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid(); // For generating unique session IDs

  DailyFocusRepository(this._firestore);

  // Helper to format today's date as DD-MM-YYYY
  String _getTodayDocumentId() {
    final now = DateTime.now().toUtc(); // Use UTC to avoid timezone issues with daily documents
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }

  // Helper to get the start of the current day in UTC
  Timestamp _getStartOfDayTimestamp() {
    final now = DateTime.now().toUtc();
    return Timestamp.fromDate(DateTime.utc(now.day, now.month, now.year));
  }

  Future<void> addFocusSessionForToday(int secondsSpend, String tag) async {
    final String todayDocId = _getTodayDocumentId();
    final DocumentReference dailyDocRef = _firestore.collection('daily_focus_data').doc(todayDocId);

    // Create the new session data
    final FocusSession newSession = FocusSession(
      id: _uuid.v4(), // Generate a unique ID for this session
      secondsSpend: secondsSpend,
      tag: tag,
      startTime: DateTime.now(),
    );
    final Map<String, dynamic> sessionData = newSession.toFirestore();

    try {
      await dailyDocRef.set(
        {
          //'date': _getStartOfDayTimestamp(),
          'totalSecondsForDay': secondsSpend,
          'sessions': FieldValue.arrayUnion([sessionData]), // Use arrayUnion to add to array
        },
        SetOptions(merge: true), // Use merge to avoid overwriting existing data
      );
    } catch (e) {
      // Re-throw the error so it propagates to the Flutter error handling*
      rethrow;
    }
  }

  // You might also want a method to retrieve all sessions for a day
  Stream<List<FocusSession>> getTodayFocusSessions() {
    final String todayDocId = _getTodayDocumentId();
    return _firestore.collection('daily_focus_data').doc(todayDocId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final data = snapshot.data()!;
      final List<dynamic> sessionMaps = data['sessions'] ?? [];
      return sessionMaps.map((map) => FocusSession(
        id: map['id'] as String,
        secondsSpend: map['secondsSpend'] as int,
        tag: map['tag'] as String,
        startTime: (map['startTime'] as Timestamp).toDate()
      )).toList();
    });
  }
}