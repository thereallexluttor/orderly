import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:orderly/Administrator/custom_card.dart';
import 'package:orderly/Administrator/firebase_service.dart';


class AdministratorHomePage extends StatefulWidget {
  const AdministratorHomePage({super.key});

  @override
  _AdministratorHomePageState createState() => _AdministratorHomePageState();
}

class _AdministratorHomePageState extends State<AdministratorHomePage> {
  late Future<Map<String, dynamic>?> documentFields;
  String selectedKey = ""; // Variable para almacenar la clave seleccionada
  String parentDocumentId = ""; // Variable para almacenar el ID del documento padre
  Map<String, dynamic>? selectedData; // Datos seleccionados para mostrar

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    documentFields = _firebaseService.getDocumentFields();
  }

  Widget buildListView(Map<String, dynamic> data) {
    List<Widget> itemList = [];

    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        itemList.add(CustomCard(
          documentId: key,
          value: value,
          onTap: () {
            setState(() {
              selectedKey = key; // Almacena la clave del documento
              parentDocumentId = key; // Actualiza el ID del documento padre
            });
            print('Selected Document ID: $selectedKey');
            print('Parent Document ID: $parentDocumentId');
          },
        ));
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
                            child: Column(
                              children: [
                                Text('Selected Key: $selectedKey'),
                                Text('Parent Document ID: $parentDocumentId'),
                                if (selectedData != null)
                                  ...selectedData!.entries.map((entry) => Text('${entry.key}: ${entry.value}')).toList(),
                              ],
                            ),
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
