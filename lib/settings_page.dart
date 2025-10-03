import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer_model.dart';

class SettingsPage extends StatefulWidget {
const SettingsPage({ super.key });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context){
    final timerModel = Provider.of<TimerModel>(context);

    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Focus time (minutes): ${timerModel.timerFocusMinutes.round()}',
              style: timerModel.whiteTextStyle,
            ),
            SizedBox(
              width: 300,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  disabledActiveTrackColor: timerModel.interactableColor.withAlpha(30),
                  disabledInactiveTrackColor: timerModel.interactableColor.withAlpha(30),
                  disabledThumbColor: timerModel.interactableColor.withAlpha(30),
                ),
                child: Slider(
                  value: timerModel.timerFocusMinutes,
                  min: 5,
                  max: 60,
                  divisions: 11,
                  thumbColor: timerModel.interactableColor,
                  activeColor: timerModel.interactableColor,
                  inactiveColor: timerModel.interactableColor.withAlpha(60),
                  onChanged: !timerModel.focusSessionRunning
                    ? (double value) {
                      setState(() {
                        timerModel.timerFocusMinutes = value;
                        timerModel.changeTime(value.round());
                      });
                    }
                    : null,
                ),
              ),
            ),
            Text(
              'Amount of rounds: ${timerModel.amountOfRounds}',
              style: timerModel.whiteTextStyle,
            ),
            SizedBox(
              width: 300,
              child:SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  disabledActiveTrackColor: timerModel.interactableColor.withAlpha(30),
                  disabledInactiveTrackColor: timerModel.interactableColor.withAlpha(30),
                  disabledThumbColor: timerModel.interactableColor.withAlpha(30),
                ),
                child: Slider(
                value: timerModel.amountOfRounds.roundToDouble(),
                min: 1,
                max: 8,
                divisions: 7,
                thumbColor: timerModel.interactableColor,
                activeColor: timerModel.interactableColor,
                inactiveColor: timerModel.interactableColor.withAlpha(60),
                onChanged: !timerModel.focusSessionRunning
                  ? (double value) {
                    setState(() {
                      timerModel.changeRounds(value.round());
                    });
                    }
                    : null,
                ),
              ),
            ),
            Text(
              'Duration of short break: ${timerModel.timerBreakMinutes.round()}',
              style: timerModel.whiteTextStyle,
            ),
            SizedBox(
              width: 300,
              child:SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  disabledActiveTrackColor: timerModel.interactableColor.withAlpha(30),
                  disabledInactiveTrackColor: timerModel.interactableColor.withAlpha(30),
                  disabledThumbColor: timerModel.interactableColor.withAlpha(30),
                ),
                child: Slider(
                value: timerModel.timerBreakMinutes.roundToDouble(),
                min: 5,
                max: 10,
                divisions: 4,
                thumbColor: timerModel.interactableColor,
                activeColor: timerModel.interactableColor,
                inactiveColor: timerModel.interactableColor.withAlpha(60),
                onChanged: !timerModel.focusSessionRunning
                  ? (double value) {
                    setState(() {
                      timerModel.timerBreakMinutes = value;
                    });
                    }
                    : null,
                ),
              ),
            ),
            Text(
              'Duration of long break: ${timerModel.timerLongBreakMinutes.round()}',
              style: timerModel.whiteTextStyle,
            ),
            SizedBox(
              width: 300,
              child:SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  disabledActiveTrackColor: timerModel.interactableColor.withAlpha(30),
                  disabledInactiveTrackColor: timerModel.interactableColor.withAlpha(30),
                  disabledThumbColor: timerModel.interactableColor.withAlpha(30),
                ),
                child: Slider(
                value: timerModel.timerLongBreakMinutes.roundToDouble(),
                min: 20,
                max: 60,
                divisions: 4,
                thumbColor: timerModel.interactableColor,
                activeColor: timerModel.interactableColor,
                inactiveColor: timerModel.interactableColor.withAlpha(60),
                onChanged: !timerModel.focusSessionRunning
                  ? (double value) {
                    setState(() {
                      timerModel.timerLongBreakMinutes = value;
                    });
                    }
                    : null,
                ),
              ),
            ),
            Text(
              style: timerModel.whiteTextStyle.copyWith(fontSize: 40),
              'Total amount of minutes: ${timerModel.totalAmountOfMinutes.round()}'
            ),
          ],
        )
      ),
    );
  }
}