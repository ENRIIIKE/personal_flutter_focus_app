import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_application_1/daily_focus_repository.dart'; 
import 'package:flutter_application_1/focus_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  final WindowsInitializationSettings windowsInitializationSettings = 
  WindowsInitializationSettings(
    appName: 'My Focus App',
    appUserModelId: 'com.example.myfocusapp',
    guid: 'e2093e32-737e-4209-aba2-a5b6b47cb283',
  );

  final InitializationSettings initializationSettings =
  InitializationSettings(
    windows: windowsInitializationSettings
  );

  await notificationPlugin.initialize(initializationSettings);
}

Future<void> showNotification(String textToShow) async {
  const NotificationDetails details = NotificationDetails(
    windows: WindowsNotificationDetails(
    ),
  );
  await notificationPlugin.show(
    0,
    textToShow,
    '',
    details,
  );
}

class TimerModel extends ChangeNotifier{
  int selectedIndex = 0;
  Timer? timer;
  
  int state = 0;  // 0 - Focus, 1 - Short Break, 2 - Long Break
  String tag = 'Study';

  static int startMinutes = 25;
  int secondsLeft = startMinutes * 60;

  bool focusSessionRunning = false;

  double timerFocusMinutes = startMinutes.roundToDouble();
  int amountOfRounds = 4;
  int currentRound = 1;
  double timerBreakMinutes = 5;
  double timerLongBreakMinutes = 20;

  double get totalAmountOfMinutes => calculateTotalMinutes();
  int secondsSpendSoFar = 0;
  double get progress => secondsLeft / (startMinutes * 60);

  String _statusMessage = 'No sessions loaded yet.';
  String get statusMessage => _statusMessage;

  final FirebaseFirestore db = FirebaseFirestore.instance;

  late final DailyFocusRepository dailyFocusRepository;
  TimerModel() {
    dailyFocusRepository = DailyFocusRepository(db);
  }

  List<FocusSession> _todaySessions = [];
  StreamSubscription<List<FocusSession>>? _sessionSubscription;

  final TextStyle whiteTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: const Color.fromARGB(255, 255, 255, 255),
    letterSpacing: 0.5,
    //fontFamily: "Roboto",
    shadows: [
      Shadow (
        offset: Offset(1, 1),
        blurRadius: 15,
        color: const Color.fromARGB(255, 59, 59, 59),
      )
    ],
  );

  void listenToTodaySessions() {
    // Access the global dailyFocusRepository instance
    _sessionSubscription = dailyFocusRepository.getTodayFocusSessions().listen((sessions) {
      _todaySessions = sessions;
      _statusMessage = 'Loaded ${sessions.length} sessions for today.';
      notifyListeners();  
    }, onError: (error) {
      _statusMessage = 'Error loading sessions: $error';
      notifyListeners();
    });
  }

  Future<void> addFocusSession(int secondsSpend, String tag) async {
    try {
      await dailyFocusRepository.addFocusSessionForToday(secondsSpend, tag);
      _statusMessage = 'Added session of $secondsSpend seconds with tag "$tag".';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error adding session: $e';
      notifyListeners();
    }
  }

  double calculateTotalMinutes(){
    double result = 0;
    if (amountOfRounds > 0) {
      result += (amountOfRounds - 1) * (timerFocusMinutes + timerBreakMinutes);
      result += timerFocusMinutes; // Last focus session without break
      result += timerLongBreakMinutes; // Add long break at the end
    }
    else {
      result += timerFocusMinutes; // Just a single focus session
    }
    return result;
  }

  Color interactableColor = const Color.fromARGB(255, 28, 119, 255);
  final ButtonStyle focusButtons = ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 28, 119, 255),
    foregroundColor: Color.fromARGB(255, 255, 255, 255),
    padding: const EdgeInsets.all(20),
    shape: const CircleBorder(),
    elevation: 4,
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  void startTimer() {
    if (timer != null && timer!.isActive) return;
    focusSessionRunning = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft > 0) {
        secondsLeft--;
        secondsSpendSoFar++;
        notifyListeners();
      } else {
        if (currentRound != amountOfRounds) {
          if (state == 0) {
            timeForBreak(true);
          }
          else {
            timeForFocus();
          }
        }
        else if (amountOfRounds == 1 && currentRound == 1) {
            addFocusSession(secondsSpendSoFar, tag);
            currentRound = 1;
            secondsLeft = timerFocusMinutes.round() * 60;
            secondsSpendSoFar = 0;
            showNotification("Focus session completed!");
        }
        else {
          if (state == 3) {
            addFocusSession(secondsSpendSoFar, tag);
            currentRound = 1;
            secondsLeft = timerFocusMinutes.round() * 60;
            secondsSpendSoFar = 0;
            showNotification("Focus session completed!");
          }
          else {
            timeForBreak(false);
          }
        }
        stopTimer();
      }
    });
  }
  void stopTimer() {
    timer?.cancel();
    timer = null;
    focusSessionRunning = false;
    notifyListeners();
  }
  void resetTimer() {
    stopTimer();
    secondsLeft = startMinutes * 60;
    notifyListeners();
  }
  void timeForBreak(bool shortBreak) {
    if (shortBreak) {
      state = 1;
      secondsLeft = timerBreakMinutes.round() * 60;
      changeTime(timerBreakMinutes.round());
      showNotification("Time for short break");
    }
    else {
      state = 2;
      secondsLeft = timerLongBreakMinutes.round() * 60;
      changeTime(timerLongBreakMinutes.round());
      showNotification("Time for long break");
    }
    notifyListeners();
  }
  void timeForFocus() {
    state = 0;
    currentRound++;
    secondsLeft = timerFocusMinutes.round() * 60;
    changeTime(timerFocusMinutes.round());
    showNotification("Time to Focus");
    notifyListeners();
  }
  void changeTime(int newMinutes) {
    startMinutes = newMinutes;
    secondsLeft = startMinutes * 60;
    notifyListeners();
  }
  void changeRounds(int newRound) {
    amountOfRounds = newRound;
    notifyListeners();
  }
  String formatTime(int totalSeconds){
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  String stateText(){
    if (state == 0) {
      return 'Focus';
    }
    else {
      return 'Break';
    }
  }
  @override
  void dispose() {
    timer?.cancel();
    addFocusSession(secondsSpendSoFar, tag);
    super.dispose();
  }
}