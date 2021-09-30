import 'dart:convert';

import 'package:constraint_view/user_search.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:constraint_view/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterAccountPage extends StatefulWidget {
  const RegisterAccountPage({Key key}) : super(key: key);

  @override
  _RegisterAccountPageState createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  bool showRegistrationForm = false;
  bool showLoginForm = false;

  Future initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      return Firebase.initializeApp();
    } catch (e) {}
  }

  void registerAccount(String name, String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      String notificationTokenID = await FirebaseMessaging.instance.getToken();

      Map<String, String> userData = {
        "id": userCredential.user.uid,
        "name": name,
        "email": email,
        "notification_id": notificationTokenID
      };

      Future<dynamic> data = NetworkUtils.performNetworkAction(
          NetworkUtils.serverAddr + NetworkUtils.portNum,
          "/create_user",
          "post",
          data: userData);

      data.onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server error. Try again later.")));
      }).whenComplete(() {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return UserModePage();
        }));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("The password you provided is too weak.")));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("The email provided is already in use.")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("An error occured")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("An error when creating account. Try again.")));
    }
  }

  Widget buildRegistrationForm() {
    GlobalKey<FormState> registerKey = GlobalKey();
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Container(
      child: Form(
        key: registerKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 20),
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        showRegistrationForm = false;
                      });
                    },
                    child: Text("cancel"))),
            Container(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              margin: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200])),
              child: TextFormField(
                controller: nameController,
                validator: (val) {
                  if (val == "") {
                    return "Please enter your full name";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: "Full name", border: InputBorder.none),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              margin: EdgeInsets.only(top: 10, left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200])),
              child: TextFormField(
                controller: emailController,
                validator: (val) {
                  if (val == "") {
                    return "Please enter your email";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: "Email", border: InputBorder.none),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              margin: EdgeInsets.only(top: 10, left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200])),
              child: TextFormField(
                controller: passwordController,
                validator: (val) {
                  if (val == "") {
                    return "Please enter your password";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: "Password", border: InputBorder.none),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 20),
                    child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "forgot password?",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ))),
                Container(
                    margin: EdgeInsets.only(right: 20),
                    child: TextButton(
                        onPressed: () async {
                          if (registerKey.currentState.validate()) {
                            registerAccount(nameController.text,
                                emailController.text, passwordController.text);
                          }
                        },
                        child: Text("REGISTER"))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildLoginForm() {
    GlobalKey<FormState> loginKey = GlobalKey();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Container(
      child: Form(
        key: loginKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 20),
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        showLoginForm = false;
                      });
                    },
                    child: Text("cancel"))),
            Container(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              margin: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200])),
              child: TextFormField(
                controller: emailController,
                validator: (val) {
                  if (val == "") {
                    return "Please enter your email";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: "Email", border: InputBorder.none),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              margin: EdgeInsets.only(top: 10, left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200])),
              child: TextFormField(
                controller: passwordController,
                validator: (val) {
                  if (val == "") {
                    return "Please enter your password";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: "Password", border: InputBorder.none),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 20),
                    child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "forgot password?",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ))),
                Container(
                    margin: EdgeInsets.only(right: 20),
                    child: TextButton(
                        onPressed: () async {
                          if (loginKey.currentState.validate()) {
                            loginUser(
                                emailController.text, passwordController.text);
                          }
                        },
                        child: Text("LOGIN"))),
              ],
            )
          ],
        ),
      ),
    );
  }

  void loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      //When a user logs in their notification ID might need to be updated. The notification token resets
      //when the cache is cleared, the user uninstalls the app or the app is installed on a new device
      Map<String, String> updatedNotificationTokenID = {
        "notification_id": await FirebaseMessaging.instance.getToken()
      };

      Future<dynamic> data = NetworkUtils.performNetworkAction(
          NetworkUtils.serverAddr + NetworkUtils.portNum,
          "/update_user/${userCredential.user.uid}/notification_id",
          "patch",
          data: updatedNotificationTokenID);

      data.onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server error occured. Try again later.")));
      }).whenComplete(() {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return UserModePage();
        }));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Your email or password is wrong")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("An error occured")));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire().whenComplete(() {
      Utils.validateUserIsRegistered(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Visibility(
              visible: !showRegistrationForm && !showLoginForm,
              child: Container(
                alignment: Alignment.center,
                child: Wrap(
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            showRegistrationForm = !showRegistrationForm;
                          });
                        },
                        child: Text("REGISTER")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            showLoginForm = !showLoginForm;
                          });
                        },
                        child: Text("LOGIN")),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: showRegistrationForm,
              child: buildRegistrationForm(),
            ),
            Visibility(
              visible: showLoginForm,
              child: buildLoginForm(),
            )
          ],
        ),
      ),
    );
  }
}
