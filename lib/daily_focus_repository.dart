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
    print("[DEBUG] addFocusSessionForToday: Starting function.");
    final String todayDocId = _getTodayDocumentId();
    print("[DEBUG] addFocusSessionForToday: todayDocId: $todayDocId");
    final DocumentReference dailyDocRef = _firestore.collection('daily_focus_data').doc(todayDocId);
    print("[DEBUG] addFocusSessionForToday: dailyDocRef created.");

    // Create the new session data
    final FocusSession newSession = FocusSession(
      id: _uuid.v4(), // Generate a unique ID for this session
      secondsSpend: secondsSpend,
      tag: tag,
      startTime: DateTime.now(),
    );
    final Map<String, dynamic> sessionData = newSession.toFirestore();
    print("[DEBUG] addFocusSessionForToday: sessionData prepared: $sessionData");

    try {
      print("[DEBUG] addFocusSessionForToday: Attempting direct set (no transaction)...");
      await dailyDocRef.set(
        {
          'date': _getStartOfDayTimestamp(),
          'totalSecondsForDay': secondsSpend,
          'sessions': FieldValue.arrayUnion([sessionData]), // Use arrayUnion to add to array
        },
        SetOptions(merge: true), // Use merge to avoid overwriting existing data
      );
      print("[DEBUG] addFocusSessionForToday: Direct set completed successfully.");

      /*
      print("[DEBUG] addFocusSessionForToday: Running transaction...");
      await _firestore.runTransaction((transaction) async {
        print("[DEBUG] addFocusSessionForToday: Inside transaction. Getting daySnapshot...");
        final DocumentSnapshot daySnapshot = await transaction.get(dailyDocRef);
        print("[DEBUG] addFocusSessionForToday: daySnapshot exists: ${daySnapshot.exists}");

        if (!daySnapshot.exists) {
          print("[DEBUG] addFocusSessionForToday: Document doesn't exist. Setting new document.");
          // Day document does not exist, create it
          transaction.set(dailyDocRef, {
            'date': _getStartOfDayTimestamp(),
            'totalSecondsForDay': secondsSpend,
            'sessions': [sessionData], // Start with the first session
          });
          print("[DEBUG] addFocusSessionForToday: Set operation performed.");
        } else {
          // Day document exists, update it
          // You can retrieve existing data if needed, but for arrayUnion and increment, it's not always required
          print("[DEBUG] addFocusSessionForToday: Document exists. Updating document.");
          transaction.update(dailyDocRef, {
            'totalSecondsForDay': FieldValue.increment(secondsSpend),
            'sessions': FieldValue.arrayUnion([sessionData]), // Add the new session to the array
          });
          print("[DEBUG] addFocusSessionForToday: Update operation performed.");
        }
        print("[DEBUG] addFocusSessionForToday: Transaction logic complete.");
        print("Focus session added/updated successfully for $todayDocId!");
      });
      */
    } catch (e) {
      print("[DEBUG] addFocusSessionForToday: CAUGHT EXCEPTION: $e");
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