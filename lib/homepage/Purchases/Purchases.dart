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
    DateTime oneWeekAgo = now.subtract(const Duration(days: 7));

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

  void _showStatsModal(BuildContext context, double totalSpent, Map<String, int> productCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        final numberFormat = NumberFormat('#,##0', 'es_ES');
        final screenWidth = MediaQuery.of(context).size.width;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Estadísticas de la última semana',
                  style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: screenWidth * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto total gastado:',
                      style: TextStyle(fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'COP ${numberFormat.format(totalSpent)}',
                      style: TextStyle(fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Productos más comprados:',
                style: TextStyle(fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...productCount.entries.map((entry) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: "Poppins", fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Cantidad: ${entry.value}',
                      style: TextStyle(fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0', 'es_ES');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Mis compras 💰',
          style: TextStyle(fontFamily: "Poppins", fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.black),
            onPressed: () async {
              final purchaseData = await _fetchPurchaseData();
              if (purchaseData != null && purchaseData['compras'] != null) {
                final metrics = _calculateMetrics(purchaseData['compras']);
                _showStatsModal(context, metrics['totalSpent'], metrics['productCount']);
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: FadeTransition(
          opacity: _animation!,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _fetchPurchaseData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No se encontraron compras.'));
              }

              Map<String, dynamic> purchaseData = snapshot.data!['compras'] ?? {};
              if (purchaseData.isEmpty) {
                return const Center(child: Text('No has realizado ninguna compra.'));
              }

              List<MapEntry<String, dynamic>> sinEntregar = purchaseData.entries
                  .where((entry) => entry.value['delivery_status'] == 'no')
                  .toList();
              List<MapEntry<String, dynamic>> entregadas = purchaseData.entries
                  .where((entry) => entry.value['delivery_status'] == 'yes')
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 20),
                  if (sinEntregar.isNotEmpty) ...[
                    const Text(
                      'Sin Entregar:',
                      style: TextStyle(fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...sinEntregar.map((entry) {
                      Map<String, dynamic> item = entry.value;

                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
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
                                  style: const TextStyle(fontFamily: "Poppins", fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'X${item['cantidad']}',
                                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('COP ${numberFormat.format(item['total_pagar'])}'),

                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                child: Text(
                                  'Fecha de Compra: ${item['fecha_compra']}',
                                  style: const TextStyle(fontFamily: "Poppins", fontSize: 10, color: Colors.black45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  if (entregadas.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Entregadas:',
                      style: TextStyle(fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...entregadas.map((entry) {
                      Map<String, dynamic> item = entry.value;

                      return Card(
                        elevation: 0,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
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
                                  style: const TextStyle(fontFamily: "Poppins", fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'X${item['cantidad']}',
                                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('COP ${numberFormat.format(item['total_pagar'])}'),
                                    Text(
                                      item['delivery_status'] ?? 'N/A',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: "Poppins",
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                child: Text(
                                  'Fecha de Compra: ${item['fecha_compra']}',
                                  style: const TextStyle(fontFamily: "Poppins", fontSize: 10, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
