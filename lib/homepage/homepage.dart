// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/homepage/Purchases/Purchases.dart';
import 'package:orderly/homepage/StoreHomePage/StoreHomePage.dart';
import 'package:orderly/homepage/UserChats/UserChats.dart';
import 'package:orderly/homepage/sales&deals/offers_tab.dart';
import 'package:orderly/homepage/shopping_cart/shopping_cart.dart';
import 'package:orderly/homepage/User/User.dart';
import 'package:orderly/homepage/tabbar/TabItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  void printUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (int i = 0; i < 20; i++) {
        print(user.uid);
      }
    }
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  List<Map<String, dynamic>> filterItems(List<Map<String, dynamic>> items) {
    return items
        .where((item) => item['nombre'].toLowerCase().contains(searchQuery))
        .toList();
  }

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
    final List<Widget> _pages = <Widget>[
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
                    SizedBox(height: 50),
                    PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        child: Container(
                          height: 30,
                          width: 240,
                          margin: const EdgeInsets.symmetric(horizontal: 60),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                            color: Colors.purple.shade50,
                          ),
                          child: const TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Color.fromARGB(137, 92, 92, 92),
                            tabs: [
                              TabItem(title: 'Ofertas!🤟'),
                              TabItem(title: 'Catalogo.📖'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 15),
                              Expanded(
                                child: OffersTab(searchQuery: searchQuery),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: 0),
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

                                          return StoreHomePage(
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
            ],
          ),
        ),
      ),
      ChatInfoScreen(),
      ShoppingCart(),
      Purchases(),
      UserPage(),
      UserPage(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_pageIndex], // Cambiar el widget que se muestra según el índice
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('lib/images/interfaceicons/artificial-intelligence.png'),
              size: 20,
            ),
            activeIcon: ImageIcon(
              AssetImage('lib/images/interfaceicons/artificial-intelligence2.png'),
              size: 20,
            ),
            label: 'AI',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Compras',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            label: 'Perfil',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "Poppins",
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: "Poppins",
          fontSize: 10,
        ),
      ),
    );
  }
}
