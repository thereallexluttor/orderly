// ignore_for_file: prefer_const_constructors

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderly/homepage/HomePage.dart';
import 'package:orderly/homepage/ProductPurchase/ProductChat/ProductChat.dart';
import 'package:orderly/homepage/ProductPurchase/purchase_page_header.dart';
import 'package:orderly/homepage/ProductPurchase/widget/order_summary_bottom_sheet.dart';
import 'package:orderly/homepage/ProductPurchase/widget/quantity_controls.dart';
import 'package:orderly/homepage/ProductPurchase/widget/product_details.dart';
import 'package:orderly/homepage/ProductPurchase/widget/confetti_widget.dart';
import 'package:orderly/homepage/ProductPurchase/utils/order_helpers.dart';

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
    _initializeControllers();
    _startInitialAnimation();
  }

  void _initializeControllers() {
    _confettiController = ConfettiController(duration: kConfettiDuration);
    _animationController = AnimationController(
      duration: kAnimationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 0.95).animate(_animationController);
  }

  void _startInitialAnimation() {
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

    _playConfettiAndCloseSheet();
    _navigateToHomePageWithDelay();

    await _saveOrderToFirestore(user);
    setState(() {
      _quantity = 1; // Reinicia el contador de productos a 1
    });
  }

  void _playConfettiAndCloseSheet() {
    _confettiController.play();
    Navigator.pop(context);
  }

  void _navigateToHomePageWithDelay() {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );
    });
  }

  Future<void> _saveOrderToFirestore(User user) async {
    Map<String, dynamic> orderData = buildOrderData(widget.itemData, _quantity);
    await saveToCarrito(widget.itemData, orderData, user.uid);
    await saveToUserCollection(orderData, user.uid);
  }

  void _showBottomSheet() {
    int totalPagar = calculateTotal(widget.itemData['precio'], widget.itemData['discount'], _quantity);

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) => OrderSummaryBottomSheet(
        totalPagar: totalPagar,
        quantity: _quantity,
        onConfirmOrder: _confirmOrder,
      ),
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

  @override
  Widget build(BuildContext context) {
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ProductDetails(itemData: widget.itemData, quantity: _quantity),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: CustomConfettiWidget(controller: _confettiController),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset('lib/images/interfaceicons/message.png', height: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    createFadeRoute(ProductChat(widget.itemData)),
                  );
                },
                tooltip: 'Mensaje',
              ),
              QuantityControls(
                quantity: _quantity,
                increment: _incrementQuantity,
                decrement: _decrementQuantity,
                animation: _animation,
              ),
              IconButton(
                onPressed: _showBottomSheet,
                icon: Icon(Icons.shopping_cart_checkout_outlined),
                color: Colors.purple,
                tooltip: 'Carrito de compras',
                iconSize: 23.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route createFadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}