import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LogAndSign extends StatelessWidget {
  const LogAndSign({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              const Center(
                child: Image(
                  image: AssetImage("lib/images/OrderlyLogoLogin.png"),
                  height: 140,
                  width: 140,
                ),
              ),
              const SizedBox(height: 150),
              const TextChangingWidget(),
              const Padding(
                padding: EdgeInsets.only(left: 22.0),
                child: Text(
                  'Hoy podrás ordenar, sin filas y muy facil. 😎',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              const SizedBox(height: 90),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Ingresa aquí:',
                        style: TextStyle(
                          color: Color.fromARGB(255, 92, 92, 92),
                          fontFamily: "Poppins",
                          fontSize: 11
                          //fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await handleLocationPermission(context);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(270, 33),
                      elevation: 0,
                      side: const BorderSide(color: Color.fromARGB(255, 230, 230, 230)),
                      surfaceTintColor: Colors.white,
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 0.0), // Ajusta el valor según sea necesario
                              child: Image(
                                image: AssetImage('lib/images/interfaceicons/google.png'),
                                width: 20, // Ajusta el tamaño según sea necesario
                                height: 25,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Center(
                            child: Text(
                              'Iniciar sesión con Google',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleLocationPermission(BuildContext context) async {
    if (await Permission.location.isGranted) {
      await signInWithGoogle();
    } else {
      await Permission.location.request();
      if (await Permission.location.isDenied) {
        showLocationPermissionDeniedDialog(context);
      } else if (await Permission.location.isGranted) {
        await signInWithGoogle();
      }
    }
  }

  void showLocationPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permiso de ubicación requerido'),
          content: const Text(
              'Debe aceptar los permisos de ubicación para poder usar la app.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.location.request();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      // Imprimir el nombre del usuario para fines de depuración
      print(userCredential.user?.displayName);
    } catch (e) {
      print('Error during Google sign in: $e');
    }
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
          fontSize: 25,
          fontFamily: "Poppins",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
