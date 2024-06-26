// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:orderly/homepage/StoreHomePage/StoreHeader.dart';


class StoreHomePage extends StatelessWidget {
  final Map<String, dynamic> storeData;

  const StoreHomePage({super.key, required this.storeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // White background
        child: StoreHeader(
          bannerUrl: storeData['banner'] ?? '',
          logoUrl: storeData['logo'] ?? '',
          storeName: storeData['nombre'] ?? 'Store Name',
          stars: storeData['stars']?.toString() ?? 'N/A',
          sales: storeData['numero_ventas']?.toString() ?? 'N/A',
          discount: storeData['descuento'],
          minimumPurchase: storeData['compra_minima'],
          description: storeData['descripcion']
        ),
      ),
    );
  }
}

