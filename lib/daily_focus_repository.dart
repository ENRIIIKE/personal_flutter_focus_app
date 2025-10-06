import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Add uuid package to pubspec.yaml for unique IDs
import 'package:flutter_application_1/focus_session.dart';

class DailyFocusRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid(); // For generating unique session IDs

  DailyFocusRepository(this._firestore);

  // Helper to format today's date as YYYY-MM-DD
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
    );
    final Map<String, dynamic> sessionData = newSession.toFirestore();

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot daySnapshot = await transaction.get(dailyDocRef);

        if (!daySnapshot.exists) {
          // Day document does not exist, create it
          transaction.set(dailyDocRef, {
            'date': _getStartOfDayTimestamp(),
            'totalSecondsForDay': secondsSpend,
            'sessions': [sessionData], // Start with the first session
          });
        } else {
          // Day document exists, update it
          // You can retrieve existing data if needed, but for arrayUnion and increment, it's not always required
          transaction.update(dailyDocRef, {
            'totalSecondsForDay': FieldValue.increment(secondsSpend),
            'sessions': FieldValue.arrayUnion([sessionData]), // Add the new session to the array
          });
        }
      });
      print("Focus session added/updated successfully for $todayDocId!");
    } catch (e) {
      print("Error adding focus session: $e");
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
      )).toList();
    });
  }
}