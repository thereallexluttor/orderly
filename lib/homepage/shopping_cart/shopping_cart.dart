// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'auth_service.dart';
import 'cart_service.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  AnimationController? _controller;
  Animation<double>? _animation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
    _controller?.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat('#,##0', 'es_CO');
    return formatter.format(amount);
  }

  Future<void> _updateScreen() async {
    // Reinicia la animación antes de actualizar la pantalla
    await _controller?.reverse();
    setState(() {
      _controller?.forward();  // Reproduce la animación nuevamente
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Tu carrito de compras. 🛒',
          style: TextStyle(fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _animation!,
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _cartService.fetchCartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No se encontraron datos del carrito.'));
                }

                Map<String, dynamic> cartData = snapshot.data!['carrito_compra'] ?? {};
                if (cartData.isEmpty) {
                  return Center(child: Text('El carrito está vacío.',style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: Colors.grey,
                  ),));
                }

                double totalPrice = cartData.values.fold(0.0, (sum, item) => sum + item['total_pagar']);

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
                              await _cartService.deleteItemFromCart(key, item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item['nombre_producto']} eliminado del carrito')),
                              );
                              await _updateScreen();  // Actualizar pantalla con efecto de desvanecimiento
                            },
                            background: Container(
                              color: Colors.red[900],
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
                                style: TextStyle(fontFamily: "Poppins", fontSize: 8, fontWeight: FontWeight.bold),
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
                            onPressed: () async {
                              await _cartService.completePurchase(_confettiController);
                              await _updateScreen();  // Actualizar pantalla después de completar la compra
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              minimumSize: Size(double.infinity, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
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
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }
}
