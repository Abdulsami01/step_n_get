import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/pointsprovider.dart';
import '../provider/userauth.dart';

class RedeemScreen extends StatefulWidget {
  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  List<Redemption> redemptions = [];

  @override
  void initState() {
    super.initState();
    _fetchRedemptions();
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

  Future<void> _fetchRedemptions() async {
    final userId = context.read<UserProvider>().userId;
    if (userId != null) {
      final redemptionsQuery = FirebaseFirestore.instance
          .collection('redemptions')
          .where('userId', isEqualTo: userId);

      final snapshots = await redemptionsQuery.get();

      setState(() {
        redemptions = snapshots.docs.map((doc) {
          return Redemption.fromDocument(doc);
        }).toList();
      });
    }
  }

  Widget build(BuildContext context) {
    final pointsProvider = context.watch<PointsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Redeem',
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
          Text(
            'Points', // Replace with the actual points value
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
              TextButton(
                onPressed: () {
                  _showRedemptionDialog(context);
                },
                child: const Text(
                  'Choose Redemption',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: redemptions.length,
              itemBuilder: (context, index) {
                final redemption = redemptions[index];
                return ListTile(
                  title: Text(redemption.phoneNumber),
                  subtitle: Text(
                    /*  isRedeemed ? 'Redeemed' : 'Pending', */
                    "Points : ${redemption.points}",
                  ),
                  trailing: Text(
                    redemption.isredeemed ? 'Redeemed' : 'Pending',
                    style: TextStyle(
                      color: redemption.isredeemed ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showRedemptionDialog(BuildContext context) {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Redemption"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Points"),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              // Validate and save the entered values
              String phoneNumber = phoneNumberController.text;
              String points = pointsController.text;

              // Perform any validation you need here

              // Store the values in Firestore (replace with your Firestore code)
              final userId = context.read<UserProvider>().userId;
              if (userId != null) {
                FirebaseFirestore.instance.collection('redemptions').add({
                  'userId': userId,
                  'phoneNumber': phoneNumber,
                  'points': points,
                  'isRedeemed': false
                });
              }

              // Close the dialog
              Navigator.of(context).pop();
            },
            child: Text("Submit"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      );
    },
  );
}

class Redemption {
  final String id;
  final String userId;
  final String phoneNumber;
  final String points;
  final bool isredeemed;

  Redemption(
      {required this.id,
      required this.userId,
      required this.phoneNumber,
      required this.points,
      required this.isredeemed});

  factory Redemption.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Redemption(
        id: doc.id,
        userId: data['userId'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        points: data['points'] ?? '',
        isredeemed: data['isRedeemed'] ?? false);
  }
}
