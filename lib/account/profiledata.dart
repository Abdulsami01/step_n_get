import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:step_n_get/screens/bottom_navBar.dart';

import '../provider/pointsprovider.dart';

class ProfileData extends StatefulWidget {
  @override
  State<ProfileData> createState() => _ProfileDataState();
}

class _ProfileDataState extends State<ProfileData> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? selectedDate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: 250,
                  child: Image.asset(
                    'assets/logo.png',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter First Name";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _secondNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Last Name";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a phone number";
                          } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email ( Optional ) Get extra 10 points ',
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedDate != null
                                      ? DateFormat.yMMMd().format(selectedDate!)
                                      : 'Date of Birth',
                                  style: TextStyle(
                                    color: selectedDate != null
                                        ? Colors.black
                                        : Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[400],
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _uploadData,
                          child: Text(
                            'Save',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1500),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      final DateTime now = DateTime.now();
      int age = now.year - picked.year;

      if (now.month < picked.month ||
          (now.month == picked.month && now.day < picked.day)) {
        // Subtract 1 from the age if the current date is before the birthdate in the current year
        age--;
      }

      if (age >= 18) {
        setState(() {
          selectedDate = picked;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Age Validation'),
              content: Text('You must be 18 years or older to continue.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  ///signup

  Future<void> _uploadData() async {
    String uid = _auth.currentUser!.uid;
    if (_formKey.currentState!.validate()) {
      // Check if email and phone are empty and set them to null if they are
      String? email = _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim();
      String? phone = _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim();

      // Create a map of the fields you want to update
      Map<String, dynamic> updatedData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _secondNameController.text.trim(),
        'dateOfBirth': selectedDate.toString(),
      };

      // Add email and phone to the map if they are not null
      if (email != null) {
        updatedData['email'] = email;
      }
      if (phone != null) {
        updatedData['phone'] = phone;
      }

      // Reference to the user's profile document
      DocumentReference profileDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc(uid);

      // Check if the profile document exists
      bool profileDocExists = (await profileDocRef.get()).exists;

      // Update the profile document or create it if it doesn't exist
      await profileDocRef
          .set(updatedData, SetOptions(merge: true))
          .then((_) async {
        // Data updated or created successfully
        // Add 10 points if the email is provided
        if (email != null && !profileDocExists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('points')
              .add({
            'emailBonusPoints': 10, // You can adjust the points as needed
            'timestamp': FieldValue.serverTimestamp(),
          });
          // ignore: use_build_context_synchronously
          //  await context.read<PointsProvider>().updatePoints(uid, 20);
        }
        await context.read<PointsProvider>().updatePoints(uid, 232);
        Fluttertoast.showToast(
          msg: "Data updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBar(),
          ),
        );
      }).catchError((error) {
        // Error updating data
        Fluttertoast.showToast(
          msg: "Error updating data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      });
    } else {
      // Handle form validation errors
      Fluttertoast.showToast(
        msg: "Please fill in all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
