import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:orderly/homepage/ProductPurchase/CardPricePurchase.dart';
import 'package:orderly/homepage/ProductPurchase/ProductChat/ProductChat.dart';
import 'package:orderly/homepage/ProductPurchase/purchase_page_header.dart';
import 'package:orderly/homepage/StoreHomePage/StoreHomePage.dart';
import 'package:orderly/homepage/HomePage.dart'; // Asegúrate de importar HomePage correctamente

class ProductPurchase extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ProductPurchase({super.key, required this.itemData});

  @override
  _ProductPurchaseState createState() => _ProductPurchaseState();
}

class _ProductPurchaseState extends State<ProductPurchase> {
  double _opacity = 0.0;
  int _quantity = 1;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Mostrar confeti y colapsar el BottomSheet inmediatamente
    _confettiController.play();
    Navigator.pop(context);

    // Navegar a HomePage después de 4 segundos
    Future.delayed(Duration(seconds: 7), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Asegúrate de que HomePage esté importada y configurada correctamente
        (route) => false,
      );
    });

    DocumentReference cartRef = FirebaseFirestore.instance
        .doc('${widget.itemData['ruta']}/carritos/carritos');
    DocumentSnapshot cartSnapshot = await cartRef.get();
    Map<String, dynamic> cartData = {};

    if (cartSnapshot.exists) {
      cartData = Map<String, dynamic>.from(cartSnapshot.data() as Map);
    }

    String userId = user.uid;

    // Si no hay datos previos para este usuario, inicializamos el mapa
    if (!cartData.containsKey(userId)) {
      cartData[userId] = {};
    }

    Map<String, dynamic> userCart = Map<String, dynamic>.from(cartData[userId]);
    int newIndex = userCart.length + 1;
    int totalPagar = (widget.itemData['precio'] * ((100 - widget.itemData['discount']) / 100)).round() * _quantity;

    // Obtener la fecha y hora actual
    String fechaActual = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    Map<String, dynamic> orderData = {
      'nombre_producto': widget.itemData['nombre'],
      'precio': (widget.itemData['precio'] * ((100 - widget.itemData['discount']) / 100)).round(),
      'cantidad': _quantity,
      'ruta': widget.itemData['ruta'],
      'foto_producto': widget.itemData['foto_producto'],
      'total_pagar': totalPagar,
      'ruta_carrito': '${widget.itemData['ruta']}/carritos/carritos', // Añade esta línea
      'fecha': fechaActual, // Añade el campo de fecha
      'status': 'sin pagar', // Añade el campo de estado
    };

    userCart[newIndex.toString()] = orderData;
    cartData[userId] = userCart;

    await cartRef.set(cartData);

    // Guardar en /Orderly/Users/users/{user.uid}
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(userId);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    Map<String, dynamic> carritoCompraData = {};

    if (userDocSnapshot.exists) {
      carritoCompraData = Map<String, dynamic>.from(userDocSnapshot.data() as Map);
    }

    Map<String, dynamic> userCarritoCompra = Map<String, dynamic>.from(carritoCompraData['carrito_compra'] ?? {});

    userCarritoCompra[newIndex.toString()] = orderData;
    carritoCompraData['carrito_compra'] = userCarritoCompra;

    await userDocRef.set(carritoCompraData, SetOptions(merge: true));

    setState(() {
      _quantity = 1; // Reinicia el contador de productos a 1
    });
  }

  void _showBottomSheet() {
    int price = widget.itemData['precio'] ?? 0;
    int discount = widget.itemData['discount'] ?? 0;
    double discountedPrice = price * ((100 - discount) / 100);
    int totalPagar = (discountedPrice * _quantity).round();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total a pagar:',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'COP ${NumberFormat('#,##0', 'es_CO').format(totalPagar)}',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Poppins",
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _confirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: Text(
                  'Confirmar orden',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int price = widget.itemData['precio'] ?? 0;
    int discount = widget.itemData['discount'] ?? 0;
    double discountedPrice = price * ((100 - discount) / 100);
    double savings = price - discountedPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(seconds: 1),
            child: CustomScrollView(
              slivers: [
                PurchasePageHeader(itemData: widget.itemData),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                        child: Text(
                          widget.itemData['nombre'] ?? '',
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
                                widget.itemData['descripcion'] ?? '',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontFamily: "Poppins"),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(indent: 6, endIndent: 6, thickness: 10, color: Color.fromARGB(14, 80, 80, 80),),
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
                                                        itemCount: widget.itemData['detalle'].length,
                                                        itemBuilder: (context, index) {
                                                          return Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: Image.network(widget.itemData['detalle'][index]),
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
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -3.14 / 2, // Confeti hacia arriba
              emissionFrequency: 0.01,
              numberOfParticles: 150,
              shouldLoop: false,
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
                  height: 23,
                ),
                onPressed: () async {
                  // Retrieve the store data from Firebase using the store reference
                  DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance.doc(widget.itemData['ruta']).get();
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
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                },
                tooltip: 'Tienda',
              ),
              IconButton(
                icon: Image.asset(
                  'lib/images/interfaceicons/message.png',
                  height: 23,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ProductChat(widget.itemData),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                },
                tooltip: 'Mensaje',
              ),
              IconButton(
                icon: Icon(Icons.remove, color: Colors.black),
                onPressed: _decrementQuantity,
                tooltip: 'Disminuir cantidad',
                iconSize: 15,
              ),
              ElevatedButton(
                onPressed: _showBottomSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 10),
                  minimumSize: const Size(80, 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 8,),
                    const Text(
                      'Agregar al carrito',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          fontFamily: "Poppins"),
                    ),
                    if (_quantity > 0)
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(left: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$_quantity',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.black),
                onPressed: _incrementQuantity,
                tooltip: 'Aumentar cantidad',
                iconSize: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
