import 'package:flutter/material.dart';
import 'package:flutter_application_1/more_icons_app.dart';
import 'package:provider/provider.dart';
import 'timer_model.dart';


class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);

    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              style: timerModel.whiteTextStyle.copyWith(fontSize: 40),
              timerModel.stateText()
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    height: 250,
                    child: SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: timerModel.progress,
                        strokeWidth: 24,
                        backgroundColor: Color.fromARGB(90, 24, 106, 230),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 24, 106, 230)),
                      ),
                    ),
                  ),
                  Text(
                    timerModel.formatTime(timerModel.secondsLeft),
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: timerModel.stopTimer, 
                  style: timerModel.focusButtons,
                  child: const Icon(MoreIconsApp.pause),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: timerModel.startTimer, 
                  style: timerModel.focusButtons,
                  child: const Icon(MoreIconsApp.play, size: 30)
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: timerModel.resetTimer,
                  style: timerModel.focusButtons,
                  child: const Icon(MoreIconsApp.ccw),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              style: timerModel.whiteTextStyle,
              '${timerModel.currentRound} of ${timerModel.amountOfRounds} rounds',
            ),
          ],
        ),
      ),
    );
  }
}