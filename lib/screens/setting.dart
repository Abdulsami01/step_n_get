import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_n_get/account/my_account.dart';
import 'package:step_n_get/account/profiledata.dart';
import 'package:step_n_get/account/register.dart';
import 'package:step_n_get/screens/about.dart';
import 'package:step_n_get/screens/contact_Screen.dart';
import 'package:step_n_get/screens/demo_points.dart';
import 'package:step_n_get/screens/how_it_works.dart';
import 'package:step_n_get/screens/privacy.dart';
import 'package:step_n_get/screens/social.dart';
import 'package:step_n_get/screens/steps.dart';
import 'package:step_n_get/screens/terms_conditions.dart';
import 'package:step_n_get/screens/testing.dart';

import '../provider/userauth.dart';

class Settings extends StatelessWidget {
  //updated
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileData()),
              );
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Account'),
          //   trailing: Icon(Icons.arrow_forward_ios),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => MyAccountPage()),
          //     );
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.question_mark),
            title: Text('How it works'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HowitWorks()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Social'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SocialScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.article),
            title: Text('Terms and Conditions'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsConditions()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Contact Us'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Contact()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              context.read<UserProvider>().setUserId(null);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Register(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
