import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../user_search.dart';

class Utils {
  Utils._();

  static final String sharedPrefsEmailKey = "user_email";
  static final String sharedPrefsIdKey = "user_id";

  static void validateUserIsRegistered(BuildContext context){
    FirebaseAuth.instance.userChanges().listen((User user) async {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        String email = user.email;
        String id = user.uid;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(Utils.sharedPrefsEmailKey, email);
        prefs.setString(Utils.sharedPrefsIdKey, id);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return UserModePage();
        }));
      }
    });
  }

  static Future initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      return Firebase.initializeApp();
    } catch (e) {}
  }
}