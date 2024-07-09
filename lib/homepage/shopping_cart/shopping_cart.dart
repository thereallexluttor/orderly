// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

class Shopping_Cart extends StatefulWidget {
  const Shopping_Cart({super.key});

  @override
  _Shopping_CartState createState() => _Shopping_CartState();
}

class _Shopping_CartState extends State<Shopping_Cart> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
    _controller?.forward();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchCartData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(user.uid);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      return userDocSnapshot.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<void> _deleteItemFromCart(String itemKey, Map<String, dynamic> item) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String rutaCarrito = item['ruta_carrito'];

    DocumentReference cartRef = FirebaseFirestore.instance.doc(rutaCarrito);
    DocumentSnapshot cartSnapshot = await cartRef.get();
    if (cartSnapshot.exists) {
      Map<String, dynamic> cartData = Map<String, dynamic>.from(cartSnapshot.data() as Map);
      if (cartData.containsKey(user.uid)) {
        Map<String, dynamic> userCart = Map<String, dynamic>.from(cartData[user.uid]);
        if (userCart.containsKey(itemKey)) {
          userCart.remove(itemKey);
          cartData[user.uid] = userCart;
          await cartRef.set(cartData);
        }
      }
    }

    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(user.uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      Map<String, dynamic> carritoCompraData = Map<String, dynamic>.from(userDocSnapshot.data() as Map);
      if (carritoCompraData.containsKey('carrito_compra')) {
        Map<String, dynamic> userCarritoCompra = Map<String, dynamic>.from(carritoCompraData['carrito_compra']);
        
        String? keyToRemove;
        userCarritoCompra.forEach((key, value) {
          if (value['nombre_producto'] == item['nombre_producto'] &&
              value['cantidad'] == item['cantidad'] &&
              value['total_pagar'] == item['total_pagar']) {
            keyToRemove = key;
          }
        });

        if (keyToRemove != null) {
          userCarritoCompra.remove(keyToRemove);
          carritoCompraData['carrito_compra'] = userCarritoCompra;
          await userDocRef.set(carritoCompraData);
        }
      }
    }

    setState(() {});
  }

  Future<void> _completePurchase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(user.uid);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      Map<String, dynamic> carritoCompraData = Map<String, dynamic>.from(userDocSnapshot.data() as Map);
      Map<String, dynamic> carritoCompra = Map<String, dynamic>.from(carritoCompraData['carrito_compra'] ?? {});
      Map<String, dynamic> compras = Map<String, dynamic>.from(carritoCompraData['compras'] ?? {});

      String fechaCompra = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      carritoCompra.forEach((key, value) {
        value['status'] = 'pagado';
        value['fecha_compra'] = fechaCompra;
        compras[key] = value;
      });

      carritoCompraData['compras'] = compras;
      carritoCompraData.remove('carrito_compra');

      await userDocRef.set(carritoCompraData);
    }

    setState(() {});
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Tu carrito de compras. 🛒👀🧐',
          style: TextStyle(fontFamily: "Poppins", fontSize: 13),
        ),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _animation!,
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _fetchCartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No se encontraron datos del carrito.'));
                }

                Map<String, dynamic> cartData = snapshot.data!['carrito_compra'] ?? {};
                if (cartData.isEmpty) {
                  return Center(child: Text('El carrito está vacío.'));
                }

                double totalPrice = cartData.values.fold(0.0, (sum, item) => sum + item['total_pagar']);

                String formatCurrency(int amount) {
                  final formatter = NumberFormat('#,##0', 'es_CO');
                  return formatter.format(amount);
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartData.length,
                        itemBuilder: (context, index) {
                          String key = cartData.keys.elementAt(index);
                          Map<String, dynamic> item = cartData[key];

                          return Dismissible(
                            key: Key(key),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              await _deleteItemFromCart(key, item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item['nombre_producto']} eliminado del carrito')),
                              );
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            child: ListTile(
                              leading: Image.network(item['foto_producto'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.fill,),
                              title: Text(
                                item['nombre_producto'],
                                style: TextStyle(fontFamily: "Poppins", fontSize: 11),
                              ),
                              subtitle: Text(
                                'X${item['cantidad']}',
                                style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              trailing: Text('COP ${formatCurrency(item['total_pagar'])}'),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Total: COP ${formatCurrency(totalPrice.toInt())}',
                            style: TextStyle(fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _completePurchase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Ir a pagar',
                              style: TextStyle(fontFamily: "Poppins", fontSize: 14, color: Colors.white,  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow], // confetti colors
            ),
          ),
        ],
      ),
    );
  }
}
