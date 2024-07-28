import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/Administrator/custom_card.dart';
import 'package:orderly/Administrator/delivery_status.dart';
import 'package:orderly/Administrator/firebase_service.dart';
import 'package:orderly/homepage/tabbar/TabItem.dart';

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

  void navigateToDeliveryStatus(BuildContext context, String key, String parentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryStatusPage(
          selectedKey: key,
          parentDocumentId: parentId,
        ),
      ),
    );
  }

  Widget buildListView(Map<String, dynamic> data) {
    List<Widget> itemList = [];

    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        itemList.add(CustomCard(
          documentId: key,
          value: value,
          onTap: () {
            if (mounted) {
              setState(() {
                selectedKey = key; // Almacena la clave del documento
                parentDocumentId = key; // Actualiza el ID del documento padre
                selectedData = value; // Almacena los datos seleccionados
                //navigateToDeliveryStatus(context, key, selectedKey);
              });
            }
            print('Selected Document ID: $selectedKey');
            print('Parent Document ID: $parentDocumentId');
          },
          parentId: parentDocumentId,
        ));
      }
    });

    return ListView(children: itemList);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                      // Asignar el primer documentId como parentDocumentId si está disponible
                      if (parentDocumentId.isEmpty && snapshot.data!.isNotEmpty) {
                        parentDocumentId = snapshot.data!.keys.first;
                      }
                      return Column(
                        children: [
                          SizedBox(height: 70), // Espacio para la imagen del logo
                          PreferredSize(
                            preferredSize: const Size.fromHeight(60),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(7)),
                              child: Container(
                                height: 30, // Aumenta la altura del contenedor
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  color: Colors.purple.shade50,
                                ),
                                child: const TabBar(
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.all(Radius.circular(7)),
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Color.fromARGB(137, 92, 92, 92),
                                  tabs: [
                                    TabItem(title: 'sin enviar.👀'),
                                    TabItem(title: 'En proceso. 😏'),
                                    TabItem(title: 'Enviada. ✔️'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Contenido de la Pestaña 1
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Column(
                                    key: ValueKey<String>('tab1'),
                                    children: [
                                      Expanded(child: buildListView(snapshot.data!)),
                                    ],
                                  ),
                                ),
                                // Contenido de la Pestaña 2
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Container(
                                    key: ValueKey<String>('tab2'),
                                    color: Colors.blue, // Solo como ejemplo, aquí puedes poner otro contenido
                                  ),
                                ),
                                // Contenido de la Pestaña 3
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Container(
                                    key: ValueKey<String>('tab3'),
                                    color: Colors.green, // Solo como ejemplo, aquí puedes poner otro contenido
                                  ),
                                ),
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
              top: 5,
              left: 23,
              child: Image.asset(
                'lib/images/OrderlyLogoLogin.png',
                width: 63,
                height: 63,
              ),
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
      ),
    );
  }
}
