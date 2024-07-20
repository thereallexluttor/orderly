import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:orderly/homepage/ProductPurchase/CardPricePurchase.dart';
import 'package:orderly/homepage/ProductPurchase/ProductChat/ProductChat.dart';
import 'package:orderly/homepage/ProductPurchase/purchase_page_header.dart';
import 'package:orderly/homepage/HomePage.dart';

class ProductPurchase extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ProductPurchase({Key? key, required this.itemData}) : super(key: key);

  @override
  _ProductPurchaseState createState() => _ProductPurchaseState();
}

class _ProductPurchaseState extends State<ProductPurchase> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  int _quantity = 1;
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 0.95).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
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
      'delivery_status': 'no', // Añade el campo delivery_status
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
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Resumen del pedido',
                style: Theme.of(context).textTheme.headline6?.copyWith(fontFamily: "Poppins", fontSize: 15),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cantidad:', style: TextStyle(fontFamily: "Poppins")),
                  Text('$_quantity', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total a pagar:', style: TextStyle(fontFamily: "Poppins")),
                  Text(
                    'COP ${NumberFormat('#,##0', 'es_CO').format(totalPagar)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontFamily: "Poppins"),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
    _animateButton();
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      _animateButton();
    }
  }

  void _animateButton() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  Route createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int price = widget.itemData['precio'] ?? 0;
    int discount = widget.itemData['discount'] ?? 0;
    double discountedPrice = price * ((100 - discount) / 100);
    double savings = price - discountedPrice;

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(seconds: 1),
            child: CustomScrollView(
              slivers: [
                PurchasePageHeader(itemData: widget.itemData),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.itemData['nombre'] ?? '',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: "Poppins"),
                        ),
                        const SizedBox(height: 16),
                        CardPricePurchase(
                          discountedPrice: discountedPrice,
                          discount: discount,
                          savings: savings,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.itemData['descripcion'] ?? '',
                          style: TextStyle(fontFamily: "Poppins"),
                          textAlign: TextAlign.justify
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Compatible',
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.itemData['compatible'] ?? '',
                          style: TextStyle(fontFamily: "Poppins"),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Especificaciones',
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.itemData['especificaciones'] ?? '',
                          style: TextStyle(fontFamily: "Poppins"),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          icon: Icons.credit_card,
                          title: 'Métodos de pago',
                          subtitle: 'Nequi • PSE • Crédito • Débito • Efectivo',
                        ),
                        _buildInfoSection(
                          icon: Icons.label,
                          title: 'Detalles y Especificaciones',
                          subtitle: 'Toca para ver más información',
                          onTap: () {
                            // Your existing bottom sheet code here
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.3,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontFamily: "Poppins")),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Image.asset('lib/images/interfaceicons/message.png', height: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  createFadeRoute(ProductChat(widget.itemData)),
                );
              },
              tooltip: 'Mensaje',
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: Colors.purple),
                  onPressed: _decrementQuantity,
                  tooltip: 'Disminuir cantidad',
                  iconSize: 20,
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          '$_quantity',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.purple),
                  onPressed: _incrementQuantity,
                  iconSize: 20,
                  tooltip: 'Aumentar cantidad',
                ),
              ],
            ),
            IconButton(
              onPressed: _showBottomSheet,
              icon: Icon(Icons.shopping_cart_checkout_outlined),
              color: Colors.purple,
              tooltip: 'Carrito de compras',
              iconSize: 25.0,
            ),
          ],
        ),
      ),
    );
  }
}
