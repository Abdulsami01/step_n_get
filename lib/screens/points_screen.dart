import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/pointsprovider.dart';
import '../provider/userauth.dart';

class PointsScreen extends StatefulWidget {
  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  int _points = 0;
  bool _isTimerRunning = false;
  Timer? _timer;
  int _timerDuration = 15 * 60; // 15 minutes in seconds
  Map<String, int> _dailyPoints = {}; // Store daily points

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    setState(() {
      _isTimerRunning = true;
      _timer = Timer.periodic(oneSec, (timer) {
        if (_timerDuration <= 0) {
          timer.cancel();
          _onTimerComplete();
        } else {
          setState(() {
            _timerDuration--;
          });
        }
      });
    });
  }

  void _onTimerComplete() {
    setState(() {
      _isTimerRunning = false;
      _timer?.cancel();
      _timer = null;
    });
  }
  //
  // void _watchAds() {
  //   setState(() {
  //     _showRewardedAd();
  //     _timerDuration = 15 * 60; // Reset the timer duration
  //     _startTimer();
  //   });
  // }

  var thirdtmethod;
  RewardedAd? _rewardedAd;
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';
  @override
  void initState() {
    _createRewardedAd();
    super.initState();
    thirdtmethod = _fetchDailyPointsData();
    // Add a delay of 2 seconds before fetching points
    Future.delayed(Duration(seconds: 2), () {
      // Fetch the current user ID from UserProvider
      String? userId = context.read<UserProvider>().userId;
      print("ussrrr zaa  $userId");

      if (userId != null) {
        // Call fetchPoints with the user ID
        context.read<PointsProvider>().fetchTotalPoints(userId);
      }
    });
  }

//create Ad
  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
        onAdFailedToLoad: (error) {
          // setState(() {
          //   _rewardedAd ??= null;
          // });
          print('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  Future<void> _fetchDailyPointsData() async {
    String? userId = context.read<UserProvider>().userId;
    for (int index = 0; index < 6; index++) {
      DateTime currentDate = DateTime.now().subtract(Duration(days: index + 1));
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

      // Fetch daily points for the current date and store them in _dailyPoints
      int points = await context
          .read<PointsProvider>()
          .fetchDailyPoints(userId!, currentDate);

      setState(() {
        _dailyPoints[formattedDate] = points;
      });
    }
  }

  //shoew Ad
  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createRewardedAd();
        // Update points when the user earns a reward
        final pointsProvider = context.read<PointsProvider>();
        String? userId = context.read<UserProvider>().userId;
        pointsProvider.updatePoints(userId!, 20);
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createRewardedAd();
      });
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) => setState(() {
          _points += 20;
        }),
      );
      _rewardedAd = null;
    }
  }

  String _formatDuration(int duration) {
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pointsProvider = context.watch<PointsProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        elevation: 1,
        title: Center(
          child: Text(
            'Points',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        //  crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grade,
                color: Colors.orangeAccent,
                size: 40,
              ),
              SizedBox(width: 5),
              Text(
                '${pointsProvider.points}', // Replace with the actual points value
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Last Week',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '300',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<void>(
              future: thirdtmethod,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Display loading indicator while fetching data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Data has been fetched, build the ListView.builder
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      DateTime currentDate =
                          DateTime.now().subtract(Duration(days: index + 1));
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(currentDate);

                      return ListTile(
                        title: Text(formattedDate),
                        trailing: Text(
                          '${_dailyPoints[formattedDate] ?? 0}',
                          // Use the stored points for the specific date
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),

          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          //   onPressed: () {
          //     //_points++;
          //     _showRewardedAd();
          //     // Handle the action for watching a rewarded ad
          //     // This is for Watch Rewarded Ad x3 button
          //   },
          //   child: Text('Get 20 Points - Watch Ad'),
          // ),
          _isTimerRunning
              ? ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Wait until Times complete ${_formatDuration(_timerDuration)}')));
                  },
                  child:
                      Text('Next ad after: ${_formatDuration(_timerDuration)}'),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    setState(() {
                      _showRewardedAd();
                      _timerDuration = 15 * 60; // Reset the timer duration
                      _startTimer();
                    });
                  },
                  child: Text('Get 40 Points - Watch Ad'),
                ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    // Implement your own date formatting logic here
    // Example: 'May 28, 2023'
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    // Implement a mapping from month number to month name
    // Example: 1 -> 'January', 2 -> 'February', etc.
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
