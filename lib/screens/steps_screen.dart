import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../provider/pointsprovider.dart';
import '../provider/userauth.dart';

class StepsScreen extends StatefulWidget {
  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isEditing = false;
  int targetSteps = 10000;

  final numberFormatter = NumberFormat('#,###');

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '0';

  Timer? _resetStepsTimer;

  @override
  void dispose() {
    _textEditingController.dispose();
    _resetStepsTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _setupResetStepsTimer();
  }

  void _setupResetStepsTimer() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight =
        midnight.millisecondsSinceEpoch - now.millisecondsSinceEpoch;

    _resetStepsTimer = Timer(Duration(milliseconds: timeUntilMidnight), () {
      setState(() {
        _steps = '0';
      });
      _setupResetStepsTimer();
    });
  }

  bool pointsAddedToday = false;

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });

    // Check if points have already been added today
    if (pointsAddedToday) {
      return; // Points have already been added, no need to continue
    }

    // Check if the current steps are greater than or equal to the target steps
    if (int.parse(_steps) >= targetSteps) {
      // Add 30 points to the user's total points
      final userId = context.read<UserProvider>().userId;
      if (userId != null) {
        context
            .read<PointsProvider>()
            .updatePoints(userId, 70); // Adjust the points as needed
        print("Adding 70 points.");
        pointsAddedToday =
            true; // Set the flag to prevent multiple additions in a day
      }
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() async {
    PermissionStatus status = await Permission.activityRecognition.request();

    if (status.isGranted) {
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      _pedestrianStatusStream
          .listen(onPedestrianStatusChanged)
          .onError(onPedestrianStatusError);

      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(onStepCount).onError(onStepCountError);
    } else {
      setState(() {
        _status = 'Permission denied';
        _steps = 'Permission denied';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTargetSteps = numberFormatter.format(targetSteps);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Step Tracker',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "TODAY'S STEPS",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 26),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[100],
                    ),
                  ),
                  Container(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.pinkAccent,
                      value: int.parse(_steps) / targetSteps,
                      strokeWidth: 20,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Text(
                    _steps.toString(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Text('Daily Goal:'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ' $formattedTargetSteps',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' Steps',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.edit,
                      color: Colors.blueAccent,
                      size: 18,
                    ),
                    onTap: () {
                      setState(() {
                        isEditing = true;
                        final numericValue =
                            numberFormatter.format(targetSteps);
                        _textEditingController.text = numericValue;
                      });
                      showEditDialog();
                    },
                  )
                ],
              ),
              SizedBox(height: 46),
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.black12, width: 2)),
                height: 150,
                child: Center(
                  child: Text(' AdMob Ad'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Target Steps'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _textEditingController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final numericValue = value.replaceAll(',', '');
                final formattedValue =
                    numberFormatter.format(int.tryParse(numericValue) ?? 0);

                if (_textEditingController.text != formattedValue) {
                  _textEditingController.value =
                      _textEditingController.value.copyWith(
                    text: formattedValue,
                    selection:
                        TextSelection.collapsed(offset: formattedValue.length),
                  );
                }
              },
              decoration: InputDecoration(
                labelText: 'Enter Steps',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a value.';
                }
                final enteredSteps = int.tryParse(value.replaceAll(',', ''));
                if (enteredSteps != null &&
                    enteredSteps >= 10000 &&
                    enteredSteps <= 20000) {
                  return null;
                }
                return 'Targeted steps must be\nbetween 10,000 and 20,000.';
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    final numericValue =
                        _textEditingController.text.replaceAll(',', '');
                    targetSteps = int.parse(numericValue);
                    isEditing = false;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
