import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../provider/userauth.dart';
import '../screens/bottom_navBar.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController countryController = TextEditingController();

  TextEditingController phoneController =
      TextEditingController(text: "3331234567");
  TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  bool otpVisibility = false;
  User? user;
  String verificationID = "";
  @override
/*   void initState() {
    // TODO: implement initState
    countryController.text = "+233";
    super.initState();
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "We need to register your phone to get stepping!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      border: InputBorder.none,
                      hintText: 'Phone Number',
                      prefix: Text('+92'),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              Visibility(
                child: TextField(
                  controller: otpController,
                  decoration: InputDecoration(
                    hintText: 'OTP',
                    prefix: Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(''),
                    ),
                  ),
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                ),
                visible: otpVisibility,
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),

                  onPressed: () {
                    if (otpVisibility) {
                      verifyOTP();
                    } else {
                      loginWithPhone();
                    }
                  },
                  // Navigator.pushNamed(context, 'verify');

                  child: Text(
                    otpVisibility ? "Verify" : "Send Verfication Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*  void loginWithPhone() async {
    auth.verifyPhoneNumber(
      phoneNumber: "+92" + phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) async {
          /*   // User authenticated, now create a Firestore document for them
          final user = value.user!;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'phone': user.phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
            // Add other user data as needed
          });
          // Set the user's UID in the provider
          context.read<UserProvider>().setUserId(user.uid); */
          print("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        otpVisibility = true;
        verificationID = verificationId;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
 */

  void loginWithPhone() async {
    String phoneNumber = "+92" + phoneController.text;

    bool userExists = await checkIfUserExists(phoneNumber);

    if (userExists) {
      auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value) async {
            print("You are logged in successfully");
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          otpVisibility = true;
          verificationID = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then(
            (value) async {
              setState(() {
                user = FirebaseAuth.instance.currentUser;
              });

              if (user != null) {
                context.read<UserProvider>().setUserId(user!.uid);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .set({
                  'phone': user!.phoneNumber,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('points')
                    .doc('totalpoints')
                    .set({
                  'points': 30, // Set the initial points value as needed
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                Fluttertoast.showToast(
                  msg: "You are logged in successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavBar(),
                  ),
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Your login has failed",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          otpVisibility = true;
          verificationID = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  Future<bool> checkIfUserExists(String phoneNumber) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otpController.text);

    await auth.signInWithCredential(credential).then(
      (value) async {
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });

        if (user != null) {
          // User authenticated, create a Firestore document for them here
          context.read<UserProvider>().setUserId(user!.uid);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .set({
            'phone': user!.phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
            'byotp': "mmmmmm"
            // Add other user data as needed
            // Set the user's UID in the provider
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('points')
              .doc('totalpoints')
              .set({
            'points': 40, // Set the initial points value as needed
            'updatedAt': FieldValue.serverTimestamp(),
          });
          /*       await FirebaseFirestore.instance
              .collection('points')
              .doc(user!.uid)
              .set({
            'points': 30, // Default points value
            'updatedAt': FieldValue.serverTimestamp(),
          }); */

          Fluttertoast.showToast(
            msg: "You are logged in successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Your login has failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
    );
  }
}
