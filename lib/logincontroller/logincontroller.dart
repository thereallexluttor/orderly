import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:orderly/homepage/homepage.dart';
import 'package:orderly/personal_information/personal_information.dart';
import 'package:orderly/login/login.dart';
import 'package:permission_handler/permission_handler.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class logincontroller extends StatefulWidget {
  const logincontroller({Key? key});

  @override
  State<logincontroller> createState() => _logincontrollerState();
}

class _logincontrollerState extends State<logincontroller> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    if (await Permission.location.isGranted) {
      setState(() {
        _permissionsGranted = true;
      });
    } else {
      final status = await Permission.location.request();
      if (status.isGranted) {
        setState(() {
          _permissionsGranted = true;
        });
      }
    }
  }

  Future<bool> isPersonalInfoCompleted(User user) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(user.uid)
        .get();

    return userDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final User? user = snapshot.data;
            if (user != null) {
              return FutureBuilder<bool>(
                future: isPersonalInfoCompleted(user),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.twistingDots(
                        leftDotColor: const Color(0xFF1A1A3F),
                        rightDotColor: Color.fromARGB(255, 198, 55, 234),
                        size: 50,
                      ),
                    );
                  }

                  if (snapshot.hasData && snapshot.data == true) {
                    return HomePage();
                  } else {
                    return _permissionsGranted
                        ? PersonalInformation()
                        : Center(
                            child: LoadingAnimationWidget.twistingDots(
                              leftDotColor: const Color(0xFF1A1A3F),
                              rightDotColor: Color.fromARGB(255, 198, 55, 234),
                              size: 50,
                            ),
                          );
                  }
                },
              );
            }
          }
          return LogAndSign();
        },
      ),
    );
  }
}
