import 'package:flutter/material.dart';

class ProductPurchase extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ProductPurchase({Key? key, required this.itemData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemData['nombre'] ?? 'Product Purchase'),
      ),
      body: Center(
        child: Text('Detalles del producto: ${itemData['nombre']}'),
      ),
    );
  }
}
