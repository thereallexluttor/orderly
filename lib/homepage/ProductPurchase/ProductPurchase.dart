import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderly/homepage/ProductPurchase/CardPricePurchase.dart';
import 'package:orderly/homepage/ProductPurchase/ProductChat/ProductChat.dart';
import 'package:orderly/homepage/ProductPurchase/purchase_page_header.dart';
import 'package:orderly/homepage/StoreHomePage/StoreHomePage.dart';

class ProductPurchase extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ProductPurchase({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    int price = itemData['precio'] ?? 0;
    int discount = itemData['discount'] ?? 0;
    double discountedPrice = price * ((100 - discount) / 100);
    double savings = price - discountedPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          PurchasePageHeader(itemData: itemData), // Usa el nuevo widget
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Text(
                    itemData['nombre'] ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(.0),
                  child: Column(
                    children: [
                      
                      CardPricePurchase(
                        discountedPrice: discountedPrice,
                        discount: discount,
                        savings: savings,
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 8),
                        child: Text(
                          itemData['descripcion'] ?? '',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontFamily: "Poppins"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(indent: 6, endIndent: 6, thickness: 10, color: Color.fromARGB(14, 80, 80, 80),),
                      
                      // Add the icons and text here
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.local_shipping, color: Colors.green, size: 20,),
                                SizedBox(width: 10),
                                Column(
                                  children: [
                                    Text(
                                      'Envios a toda Colombia',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: "Poppins",
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(width: 10),
                                
                                  ],
                                ),
                                
                              ],
                            ),
                            const SizedBox(height: 8,),
                            const Row(
                              children: [
                                Icon(Icons.credit_card, color: Colors.black, size: 20,),
                                SizedBox(width: 10),
                                Text(
                                  'Nequi • PSE • Credito • Debito • Efectivo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: "Poppins",
                                    color: Colors.black
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8,),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return DraggableScrollableSheet(
                                      expand: false,
                                      builder: (BuildContext context, ScrollController scrollController) {
                                        return Container(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Detalles • Especificaciones',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Poppins"
                                                ),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Expanded(
                                                child: ListView.builder(
                                                  controller: scrollController,
                                                  itemCount: itemData['detalle'].length,
                                                  itemBuilder: (context, index) {
                                                    return Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: Image.network(itemData['detalle'][index]),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.label, color: Colors.grey, size: 20,),
                                  SizedBox(width: 10),
                                  Text(
                                    'Detalles • Especificaciones >',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: "Poppins",
                                      color: Colors.black
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 300,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 63,
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Image.asset(
                  'lib/images/interfaceicons/shop.png',
                  height: 25,
                ),
                onPressed: () async {
                  // Retrieve the store data from Firebase using the store reference
                  DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance.doc(itemData['ruta']).get();
                  var storeData = storeSnapshot.data() as Map<String, dynamic>;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => StoreHomePage(
                        storeData: storeData,
                        storeReference: storeSnapshot.reference,
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 800), // Ajusta la duración aquí
                    ),
                  );
                },
                tooltip: 'Tienda',
              ),
              IconButton(
                icon: Image.asset(
                  'lib/images/interfaceicons/message.png',
                  height: 25,
                ),
                onPressed: () {
                  // Acción para Mensaje
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ProductChat(itemData),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 800), // Ajusta la duración aquí
                    ),
                  );
                },
                tooltip: 'Mensaje',
              ),
              ElevatedButton(
                onPressed: () {
                  // Acción para agregar al carrito
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                  minimumSize: const Size(50, 36),
                ),
                child: const Text(
                  'Agregar al carrito',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: "Poppins"),
                ),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  // Acción para comprar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  minimumSize: const Size(50, 36),
                ),
                child: const Text(
                  'Comprar!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
