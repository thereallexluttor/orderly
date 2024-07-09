import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Purchases extends StatefulWidget {
  const Purchases({super.key});

  @override
  _PurchasesState createState() => _PurchasesState();
}

class _PurchasesState extends State<Purchases> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchPurchaseData() async {
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

  Map<String, dynamic> _calculateMetrics(Map<String, dynamic> purchaseData) {
    double totalSpent = 0.0;
    Map<String, int> productCount = {};
    DateTime now = DateTime.now();
    DateTime oneWeekAgo = now.subtract(Duration(days: 7));

    purchaseData.forEach((key, value) {
      if (value['fecha_compra'] != null && value['total_pagar'] != null && value['cantidad'] != null && value['nombre_producto'] != null) {
        DateTime date = DateTime.parse(value['fecha_compra']);
        double total = (value['total_pagar'] as num).toDouble();
        int cantidad = value['cantidad'] as int;

        if (date.isAfter(oneWeekAgo)) {
          totalSpent += total;

          if (productCount.containsKey(value['nombre_producto'])) {
            productCount[value['nombre_producto']] = productCount[value['nombre_producto']]! + cantidad;
          } else {
            productCount[value['nombre_producto']] = cantidad;
          }
        }
      }
    });

    return {
      'totalSpent': totalSpent,
      'productCount': productCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          'Mis compras 💫😉',
          style: TextStyle(fontFamily: "Poppins", fontSize: 13),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: FadeTransition(
          opacity: _animation!,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _fetchPurchaseData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('No se encontraron compras.'));
              }

              Map<String, dynamic> purchaseData = snapshot.data!['compras'] ?? {};
              if (purchaseData.isEmpty) {
                return Center(child: Text('No has realizado ninguna compra.'));
              }

              Map<String, dynamic> metrics = _calculateMetrics(purchaseData);
              double totalSpent = metrics['totalSpent'];
              Map<String, int> productCount = metrics['productCount'];

              List<MapEntry<String, int>> sortedProducts = productCount.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              final numberFormat = NumberFormat('#,##0', 'es_ES');

              return ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Text(
                    'Estadísticas de la última semana:',
                    style: TextStyle(fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Monto total gastado: COP ${numberFormat.format(totalSpent)}',
                    style: TextStyle(fontFamily: "Poppins", fontSize: 12),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Productos más comprados:',
                    style: TextStyle(fontFamily: "Poppins", fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  ...sortedProducts.map((entry) => ListTile(
                        title: Text(
                          entry.key,
                          style: TextStyle(fontFamily: "Poppins", fontSize: 12),
                        ),
                        trailing: Text(
                          'Cantidad: ${entry.value}',
                          style: TextStyle(fontFamily: "Poppins", fontSize: 12),
                        ),
                      )),
                  Divider(),
                  Text(
                    'Detalle de compras:',
                    style: TextStyle(fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  ...purchaseData.entries.map((entry) {
                    Map<String, dynamic> item = entry.value;

                    if (item['nombre_producto'] != null && item['cantidad'] != null && item['total_pagar'] != null && item['foto_producto'] != null && item['fecha_compra'] != null) {
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    item['foto_producto'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  item['nombre_producto'],
                                  style: TextStyle(fontFamily: "Poppins", fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'X${item['cantidad']}',
                                  style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                trailing: Text('COP ${numberFormat.format(item['total_pagar'])}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                child: Text(
                                  'Fecha de Compra: ${item['fecha_compra']}',
                                  style: TextStyle(fontFamily: "Poppins", fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SizedBox.shrink(); // Retorna un widget vacío si algún valor es nulo
                    }
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
