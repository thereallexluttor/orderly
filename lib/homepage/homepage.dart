// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/homepage/UserChats/UserChats.dart';
import 'package:orderly/homepage/product_category/category_buttons.dart';
import 'package:orderly/homepage/sales&deals/offers_tab.dart';
import 'package:orderly/homepage/sales&deals/sales&deals.dart';
import 'package:orderly/homepage/shopping_cart/shopping_cart.dart';
import 'package:orderly/homepage/tabbar/TabItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _pageIndex = 0;
  final PageController _pageController = PageController();
  User? user = FirebaseAuth.instance.currentUser;
  double _opacity = 0.0;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    printUserUid();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  // Función para imprimir el UID del usuario actual
  void printUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (int i = 0; i < 20; i++) {
        print(user.uid);
      }
    }
  }

  // Función para actualizar el término de búsqueda
  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  // Función para filtrar los resultados en las pestañas
  List<Map<String, dynamic>> filterItems(List<Map<String, dynamic>> items) {
    return items
        .where((item) => item['nombre'].toLowerCase().contains(searchQuery))
        .toList();
  }

  // Función para cambiar de página en la navegación inferior
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
    // Lista de páginas para el PageView
    final List<Widget> _pages = [
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
                    SizedBox(height: 13),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: TextField(
                          onChanged: updateSearchQuery,
                          decoration: InputDecoration(
                            constraints: BoxConstraints(maxHeight: 36),
                            hintText: "Buscar...",
                            prefixIcon: Icon(Icons.search, size: 17),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0), // Ajusta el relleno vertical
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          style: TextStyle(fontSize: 12), // Ajusta el tamaño del texto según sea necesario
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Pestaña Ofertas
                          Column(
                            children: [
                              SizedBox(height: 13),
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
                                child: OffersTab(searchQuery: searchQuery), // Utiliza el nuevo widget OffersTab
                              ),
                            ],
                          ),
                          // Pestaña Top Tiendas
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
                                    Widget content;

                                    if (!snapshot.hasData) {
                                      content = Center(child: SizedBox.shrink());
                                    } else {
                                      var stores = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
                                      var filteredStores = filterItems(stores);

                                      content = ListView.builder(
                                        itemCount: filteredStores.length,
                                        itemBuilder: (context, index) {
                                          var store = filteredStores[index];

                                          return StoreCard(
                                            storeData: store,
                                            storeReference: snapshot.data!.docs[index].reference,
                                          );
                                        },
                                      );
                                    }

                                    return AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 500),
                                      child: content,
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
      // Página central azul con información del chat
      ChatInfoScreen(),
      // Página central amarilla
      Shopping_Cart(),
      // Página central verde
      Container(color: Colors.green),
      // Última página morada
      Container(color: Colors.purple),
    ];

    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: Duration(seconds: 1),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _pageIndex = index;
            });
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 45,
        key: _bottomNavigationKey,
        index: _pageIndex,
        items: <Widget>[
          Icon(Icons.home_outlined, size: 17),
          Icon(Icons.message_outlined, size: 17),
          Icon(Icons.shopping_cart_outlined, size: 17),
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
