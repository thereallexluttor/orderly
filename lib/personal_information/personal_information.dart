// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:orderly/homepage/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:confetti/confetti.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  _PersonalInformationState createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  String? gender;
  double? latitude;
  double? longitude;
  DateTime? birthdate;
  String? phoneNumber;
  final _formKey = GlobalKey<FormState>();
  double _opacity = 0.0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _requestLocationPermission();
    _getUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _requestLocationPermission() async {
    if (await Permission.location.isGranted) {
      return;
    }
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      // Handle the situation when the user doesn't grant permission
    }
  }

  bool _validatePhoneNumber(String? number) {
    if (number == null) return false;

    String digits = number.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Image(
                    image: AssetImage("lib/images/OrderlyLogoLogin.png"),
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 2),
                  child: Card(
                    elevation: 0,
                    color: Color.fromARGB(71, 226, 226, 226),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 15,),
                            const Text(
                              'Información Personal',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color.fromARGB(255, 240, 240, 240)),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Selecciona tu género:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 15,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'lib/images/animations/man.gif',
                                            width: 20,
                                            height: 20,
                                          ),
                                          Radio<String>(
                                            activeColor: Colors.black,
                                            value: 'Hombre',
                                            groupValue: gender,
                                            onChanged: (value) {
                                              setState(() {
                                                gender = value;
                                              });
                                            },
                                          ),
                                          const Text(
                                            'Hombre',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: "Poppins",
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: const Color.fromARGB(255, 202, 202, 202),
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'lib/images/animations/woman.gif',
                                            width: 23,
                                            height: 23,
                                          ),
                                          Radio<String>(
                                            activeColor: Colors.black,
                                            value: 'Mujer',
                                            groupValue: gender,
                                            onChanged: (value) {
                                              setState(() {
                                                gender = value;
                                              });
                                            },
                                          ),
                                          const Text(
                                            'Mujer',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: "Poppins",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color.fromARGB(255, 240, 240, 240)),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (birthdate == null)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
                                      child: Text(
                                        'La fecha de nacimiento debe ser seleccionada para avanzar',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: FormBuilderDateTimePicker(
                                      name: 'Fecha de nacimiento',
                                      initialValue: birthdate ?? DateTime(1997),
                                      inputType: InputType.date,
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        labelText: 'Fecha de nacimiento',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          birthdate = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color.fromARGB(255, 240, 240, 240)),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  children: [
                                    InternationalPhoneNumberInput(
                                      maxLength: 50,
                                      onInputChanged: (PhoneNumber number) {
                                        setState(() {
                                          phoneNumber = number.phoneNumber;
                                        });
                                      },
                                      validator: (value) {
                                        if (!_validatePhoneNumber(value)) {
                                          return 'Por favor, ingrese un número de teléfono válido de Colombia.';
                                        }
                                        return null;
                                      },
                                      selectorConfig: const SelectorConfig(
                                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                        setSelectorButtonAsPrefixIcon: true,
                                        leadingPadding: 3.0,
                                      ),
                                      textStyle: const TextStyle(fontSize: 11),
                                      inputDecoration: const InputDecoration(
                                        labelText: 'Número de teléfono',
                                        labelStyle: TextStyle(fontSize: 14), // Tamaño del texto del label
                                        border: InputBorder.none,
                                      ),
                                      initialValue: PhoneNumber(isoCode: 'CO'),
                                      spaceBetweenSelectorAndTextField: 0, // Reduce el espacio entre selector y campo de texto
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 80),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isInformationComplete() && _formKey.currentState!.validate()
                          ? () => savePersonalInformation()
                          : null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.purple,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 84),
                      ),
                      child: const Text('Guardar información'),
                    ),
                    ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple
                      ],
                      createParticlePath: (size) {
                        var path = Path();
                        path.addOval(Rect.fromCircle(center: Offset(0, 0), radius: 3));
                        return path;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isInformationComplete() {
    return gender != null && birthdate != null && phoneNumber != null;
  }

  void _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  void savePersonalInformation() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('Orderly').doc('Users').collection('users').doc(user.uid).set({
        'email': user.email,
        'name': user.displayName,
        'photo': user.photoURL,
        'gender': gender,
        'latitude': latitude,
        'longitude': longitude,
        'birthdate': birthdate,
        'phoneNumber': phoneNumber,
      }).then((value) {
        _setPersonalInfoCompleted();
        _confettiController.play();
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        });
      }).catchError((error) {
        print('Error saving personal information: $error');
      });
    }
  }

  void _setPersonalInfoCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('personalInfoCompleted', true);
  }
}
