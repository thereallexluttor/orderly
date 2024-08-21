// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/Administrator/AdminHomePage.dart';
import 'package:orderly/homepage/homepage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LogAndSign extends StatefulWidget {
  const LogAndSign({super.key});

  @override
  _LogAndSignState createState() => _LogAndSignState();
}

class _LogAndSignState extends State<LogAndSign> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),
                const Center(
                  child: LogoWidget(),
                ),
                const SizedBox(height: 180),
                const TextChangingWidget(),
                const GreetingText(),
                const SizedBox(height: 20),
                const DividerWithText(text: 'Ingresa aquí:'),
                const SizedBox(height: 5),
                _buildLoginButton(
                  onPressed: () => handleLocationPermission(context),
                  iconPath: 'lib/images/interfaceicons/google.png',
                  text: 'Iniciar sesión con Google',
                ),
                const SizedBox(height: 5),
                _buildLoginButton(
                  onPressed: () => _navigateToPage(context, const AdministratorHomePage()),
                  text: 'Admin zone',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback onPressed,
    String? iconPath,
    required String text,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(300, 33),
            elevation: 1,
            side: const BorderSide(color: Color.fromARGB(255, 230, 230, 230)),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconPath != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    iconPath,
                    width: 20,
                    height: 25,
                  ),
                ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> handleLocationPermission(BuildContext context) async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      await _signInWithGoogle();
    } else {
      await Permission.location.request();
      if (await Permission.location.isGranted) {
        await _signInWithGoogle();
      } else if (await Permission.location.isDenied) {
        _showLocationPermissionDeniedDialog(context);
      }
    }
  }

  void _showLocationPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permiso de ubicación requerido'),
          content: const Text('Debe aceptar los permisos de ubicación para poder usar la app.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                Permission.location.request();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print(userCredential.user?.displayName);
    } catch (e) {
      print('Error during Google sign in: $e');
    }
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage("lib/images/OrderlyLogoLogin.png"),
      height: 140,
      width: 140,
    );
  }
}

class GreetingText extends StatelessWidget {
  const GreetingText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 22.0),
      child: Text(
        'Hoy podrás comprar lo que necesitas!. 😎',
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontFamily: "Poppins",
        ),
      ),
    );
  }
}

class DividerWithText extends StatelessWidget {
  final String text;
  const DividerWithText({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          const Expanded(
            child: Divider(thickness: 0.5, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              text,
              style: const TextStyle(
                color: Color.fromARGB(255, 156, 156, 156),
                fontFamily: "Poppins",
                fontSize: 11,
              ),
            ),
          ),
          const Expanded(
            child: Divider(thickness: 0.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class TextChangingWidget extends StatefulWidget {
  const TextChangingWidget({super.key});

  @override
  _TextChangingWidgetState createState() => _TextChangingWidgetState();
}

class _TextChangingWidgetState extends State<TextChangingWidget> {
  int _index = 0;
  final List<String> _textList = ['Bienvenido!', 'Welcome!', '¡Salut!', 'Benvenuto!'];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _index = (_index + 1) % _textList.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0),
      child: Text(
        _textList[_index],
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontFamily: "Poppins",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
