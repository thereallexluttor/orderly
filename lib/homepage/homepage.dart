// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'package:flutter/material.dart';
import 'package:orderly/homepage/product_category/category_buttons.dart';
import 'package:orderly/homepage/sales&deals/sales&deals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderly/homepage/tabbar/TabItem.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Home Page'),
         
        ),
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CategoryButton(
                    imagePath: 'lib/images/product_category/motos_y_autopartes.png',
                    label: 'motos y autopartes',
                  ),
                  SizedBox(width: 10),
                  CategoryButton(
                    imagePath: 'lib/images/product_category/moda_y_accesorios.png',
                    label: 'Moda y accesorios',
                  ),
                  SizedBox(width: 10),
                  CategoryButton(
                    imagePath: 'lib/images/product_category/deportes_y_hobbies.png',
                    label: 'deportes y hobbies',
                  ),
                  SizedBox(width: 10),
                  CategoryButton(
                    imagePath: 'lib/images/product_category/electronica_de_consumo.png',
                    label: 'electronica de consumo',
                  ),
                  SizedBox(width: 10),
                  CategoryButton(
                    imagePath: 'lib/images/product_category/hogar_y_accesorios.png',
                    label: 'Hogar y accesorios',
                  ),
                ],
              ),
              SizedBox(height: 20), // Espacio entre las categorías y los botones de venta
               
              PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(7)),
                  child: Container(
                    height: 35,
                    margin: const EdgeInsets.symmetric(horizontal: 60),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.purple.shade50,
                    ),
                    child: const TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black54,
                      tabs: [
                        TabItem(title: 'Top ventas'),
                        TabItem(title: 'Ofertas'),
                        
                      ],
                    ),
                  ),
                ),
              ),
        
              Expanded(
                child: TabBarView(
                  children: [
                    // Top Tiendas tab
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('Orderly/Stores/Stores').snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var stores = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: stores.length,
                          itemBuilder: (context, index) {
                            var store = stores[index];
                            var storeData = store.data() as Map<String, dynamic>;

                            return StoreCard(
                              storeData: storeData,
                              storeReference: store.reference,
                            );
                          },
                        );
                      },
                    ),
                    // Ofertas tab
                    Center(
                      child: Text('Ofertas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

