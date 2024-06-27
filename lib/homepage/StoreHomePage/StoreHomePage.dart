// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderly/homepage/StoreHomePage/StoreHeader.dart';
import 'package:orderly/homepage/StoreHomePage/StoreItemCard.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class StoreHomePage extends StatefulWidget {
  final Map<String, dynamic> storeData;
  final DocumentReference<Object?> storeReference;

  const StoreHomePage({super.key, required this.storeData, required this.storeReference});

  @override
  _StoreHomePageState createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  int _page = 0;
  String? selectedCategory;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Inicializar la categoría seleccionada
    _initializeSelectedCategory();
  }

  void _initializeSelectedCategory() async {
    var snapshot = await widget.storeReference.collection('items').get();
    var items = snapshot.docs;

    // Crear un mapa para obtener el producto más vendido por categoría
    Map<String, dynamic> topProducts = {};

    for (var item in items) {
      var data = item.data() as Map<String, dynamic>;
      var category = data['category'];
      if (category != null) {
        if (!topProducts.containsKey(category) || (data['ventas'] ?? 0) > (topProducts[category]['ventas'] ?? 0)) {
          topProducts[category] = data;
        }
      }
    }

    if (topProducts.isNotEmpty) {
      setState(() {
        selectedCategory = topProducts.keys.first; // Preseleccionar la primera categoría
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              surfaceTintColor: Colors.white,
              expandedHeight: 415.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: StoreHeader(
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
              ),
              pinned: true,
              automaticallyImplyLeading: false, // Aquí se desactiva el botón de retroceso
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(32), // Altura ajustada para incluir el rectángulo blanco
                child: Container(
                  color: Colors.white, // Rectángulo blanco
                  child: _buildCategoryButtons(),
                ),
              ),
            ),
          ];
        },
        body: StreamBuilder<QuerySnapshot>(
          stream: widget.storeReference
              .collection('items')
              .where('category', isEqualTo: selectedCategory)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var items = snapshot.data!.docs;

            return GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 10.0, // Espaciado horizontal entre los elementos
                mainAxisSpacing: 10.0, // Espaciado vertical entre los elementos
                childAspectRatio: 0.70, // Relación de aspecto de los elementos (ajustar según sea necesario)
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                var itemData = items[index].data() as Map<String, dynamic>;
                return StoreItemCard(itemData: itemData);
              },
            );
          },
        ),
      ),
      
    );
  }
Widget _buildCategoryButtons() {
  return StreamBuilder<QuerySnapshot>(
    stream: widget.storeReference.collection('items').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      var items = snapshot.data!.docs;

      // Crear un mapa para obtener el producto más vendido por categoría
      Map<String, dynamic> topProducts = {};

      for (var item in items) {
        var data = item.data() as Map<String, dynamic>;
        var category = data['category'];
        if (category != null) {
          if (!topProducts.containsKey(category) || (data['ventas'] ?? 0) > (topProducts[category]['ventas'] ?? 0)) {
            topProducts[category] = data;
          }
        }
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: topProducts.keys.map((category) {
            var product = topProducts[category];
            bool isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 600),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.purple, width: 1.5) : null,
                        color: isSelected ? Colors.purple.withOpacity(0.2) : Colors.transparent,
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(product['foto_producto'] ?? ''),
                        onBackgroundImageError: (error, stackTrace) {
                          // Manejar el error de carga de la imagen
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    category ?? 'Unknown',
                    style: TextStyle(fontSize: 8, fontFamily: "Poppins"),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}

}
