// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderly/homepage/StoreHomePage/CategoryButtons.dart';
import 'package:orderly/homepage/StoreHomePage/CategoryItems.dart';
import 'package:orderly/homepage/StoreHomePage/StoreHeader.dart';

class StoreHomePage extends StatefulWidget {
  final Map<String, dynamic> storeData;
  final DocumentReference<Object?> storeReference;

  const StoreHomePage({super.key, required this.storeData, required this.storeReference});

  @override
  _StoreHomePageState createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeSelectedCategory();
  }

  void _initializeSelectedCategory() async {
    var snapshot = await widget.storeReference.collection('items').get(GetOptions(source: Source.cache));
    
    if (snapshot.docs.isEmpty) {
      snapshot = await widget.storeReference.collection('items').get(GetOptions(source: Source.server));
    }
    
    var items = snapshot.docs;
    Map<String, dynamic> topProducts = {};

    for (var item in items) {
      var data = item.data();
      var category = data['category'];
      if (category != null) {
        if (!topProducts.containsKey(category) || (data['ventas'] ?? 0) > (topProducts[category]['ventas'] ?? 0)) {
          topProducts[category] = data;
        }
      }
    }

    if (topProducts.isNotEmpty) {
      setState(() {
        selectedCategory = topProducts.keys.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              surfaceTintColor: Colors.white,
              expandedHeight: 365.0,
              flexibleSpace: FlexibleSpaceBar(
                background: StoreHeader(
                  bannerUrl: widget.storeData['banner'] ?? '',
                  logoUrl: widget.storeData['logo'] ?? '',
                  storeName: widget.storeData['nombre'] ?? 'Store Name',
                  stars: widget.storeData['stars']?.toString() ?? 'N/A',
                  sales: widget.storeData['numero_ventas']?.toString() ?? 'N/A',
                  discount: widget.storeData['descuento'],
                  minimumPurchase: widget.storeData['compra_minima'],
                  description: widget.storeData['descripcion'],
                ),
              ),
              pinned: true,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
                  child: CategoryButtons(
                    storeReference: widget.storeReference,
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: CategoryItems(
          storeReference: widget.storeReference,
          selectedCategory: selectedCategory,
        ),
      ),
    );
  }
}
