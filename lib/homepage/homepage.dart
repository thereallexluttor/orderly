// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'package:flutter/material.dart';
import 'package:orderly/homepage/product_category/category_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderly/homepage/sales&deals/sales&deals.dart';
import 'package:orderly/homepage/tabbar/TabItem.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:orderly/homepage/sales&deals/offers_tab.dart'; // Import the new OffersTab widget

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _pageIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    // Home Page with the TabBar and other elements
    DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  SizedBox(height: 70), // Espacio para la imagen del logo
                  PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                      child: Container(
                        height: 30,
                        width: 240,
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
                          unselectedLabelColor: Color.fromARGB(137, 92, 92, 92),
                          tabs: [
                            TabItem(title: 'Ofertas!🤟'),
                            TabItem(title: 'Top tiendas.😎🤍'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Top Ventas tab
                        
                        // Ofertas tab
                        Column(
                          children: [
                            SizedBox(height: 20),
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
                            SizedBox(height: 20), // Espacio entre las categorías y las ofertas
                            Expanded(
                              child: OffersTab(), // Use the new OffersTab widget here
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            SizedBox(height: 20),
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
                            SizedBox(height: 0), // Espacio entre las categorías y los productos
                            Expanded(
                              child: StreamBuilder(
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 23,
              left: 23,
              child: Image.asset(
                'lib/images/OrderlyLogoLogin.png',
                width: 63, // Ajusta el tamaño de la imagen según sea necesario
                height: 63,
              ),
            ),

            
          ],
        ),
      ),
    ),
    // Middle Button Page
    Container(color: Colors.green),
    // Last Button Page
    Container(color: Colors.purple),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 45,
        key: _bottomNavigationKey,
        index: _pageIndex,
        items: <Widget>[
          Icon(Icons.home_outlined, size: 17),
          Icon(Icons.shopping_bag_outlined, size: 17),
          Icon(Icons.perm_identity, size: 17),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 249, 217, 255),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 200),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
    );
  }
}
