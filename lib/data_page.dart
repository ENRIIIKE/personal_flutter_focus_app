import 'package:flutter/material.dart';
import 'package:flutter_application_1/timer_model.dart';
import 'package:provider/provider.dart';


class DataPage extends StatefulWidget {
  const DataPage({ Key? key }) : super(key: key);

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {

  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: 
              Text(
                'data'
              ),
            ),
          ],
        ),
      ),
    );
  }
}