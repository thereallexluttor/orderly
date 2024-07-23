// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AdministratorHomePage(),
    );
  }
}

class AdministratorHomePage extends StatefulWidget {
  const AdministratorHomePage({super.key});

  @override
  _AdministratorHomePageState createState() => _AdministratorHomePageState();
}

class _AdministratorHomePageState extends State<AdministratorHomePage> {
  late Future<Map<String, dynamic>?> documentFields;
  String selectedKey = ""; // Variable para almacenar la clave seleccionada

  @override
  void initState() {
    super.initState();
    documentFields = getDocumentFields();
  }

  Future<Map<String, dynamic>?> getDocumentFields() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .doc('/Orderly/Stores/Stores/WOLFSGROUP SAS/compras/compras');

    DocumentSnapshot docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>?;
    } else {
      return null;
    }
  }

  Future<void> updateDeliveryStatus(String documentId, String status) async {
    if (documentId.isNotEmpty) {
      DocumentReference docRef = FirebaseFirestore.instance
          .doc('/Orderly/Stores/Stores/WOLFSGROUP SAS/compras/compras');

      print('Selected Key: $selectedKey'); // Imprime la clave seleccionada para depuración

      print('Updating document ID: $documentId with status: $status');

      await docRef.update({'delivery_status': status});

      setState(() {
        documentFields = getDocumentFields(); // Refresh the data after updating
      });
    } else {
      print('Invalid document ID');
    }
  }

  List<Widget> buildNestedList(Map<String, dynamic> data, String documentId) {
    List<Widget> itemList = [];
    String firstKey = ""; // Variable para almacenar la primera clave de la card

    data.forEach((key, value) {
      if (firstKey.isEmpty) {
        firstKey = key; // Almacena la primera clave
      }

      if (value is Map) {
        itemList.add(
          GestureDetector(
            onTap: () {
              setState(() {
                selectedKey = key; // Actualiza la clave seleccionada aquí
              });
              print('Selected Key on Tap: $selectedKey');
            },
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    ...buildNestedList(Map<String, dynamic>.from(value), documentId),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (value is List) {
        itemList.add(
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 255, 62, 62)),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  ...value.map((item) {
                    if (item is Map) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildNestedList(Map<String, dynamic>.from(item), documentId),
                      );
                    } else {
                      return Text('$item', style: const TextStyle(fontSize: 10));
                    }
                  }).toList()
                ],
              ),
            ),
          ),
        );
      } else if (key == 'foto_producto' && value is String) {
        itemList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(value, height: 150),
            ),
          ),
        );
      } else if (key == 'delivery_status' && value is String) {
        itemList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text(
                  '$key: ',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      } else if (['precio', 'nombre_producto', 'cantidad', 'total_pagar', 'status'].contains(key)) {
        itemList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '$key: $value',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }
    });

    return itemList;
  }

  Widget buildCard(String documentId, Map<String, dynamic> value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedKey = documentId; // Almacena la clave del documento
        });
        print('Selected Document ID: $selectedKey');
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(10),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.containsKey('foto_producto') && value['foto_producto'] is String)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    value['foto_producto'],
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ...buildNestedList(value, documentId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListView(Map<String, dynamic> data) {
    List<Widget> itemList = [];

    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        itemList.add(buildCard(key, value));
      }
    });

    return ListView(children: itemList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Center(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: documentFields,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('No hay datos disponibles');
                  } else {
                    return Column(
                      children: [
                        Expanded(child: buildListView(snapshot.data!)),
                        if (selectedKey.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Selected Key: $selectedKey'),
                          ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 23,
            child: Image.asset(
              'lib/images/OrderlyLogoLogin.png',
              width: 63,
              height: 63),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 45,
        items: <Widget>[
          const Icon(Icons.shopping_cart_checkout_outlined, size: 17),
          const Icon(Icons.message_outlined, size: 17),
          const Icon(Icons.qr_code_scanner_outlined, size: 23),
          const Icon(Icons.edit_document, size: 17),
          const Icon(Icons.data_exploration_outlined, size: 17),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.purple,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          // Implementa la lógica de navegación aquí si es necesario
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
