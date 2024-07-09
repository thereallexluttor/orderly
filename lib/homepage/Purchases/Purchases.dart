import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        color: Colors.white, // Fondo blanco para la pantalla
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

              return ListView.builder(
                itemCount: purchaseData.length,
                itemBuilder: (context, index) {
                  String key = purchaseData.keys.elementAt(index);
                  Map<String, dynamic> item = purchaseData[key];

                  return Card(
                    elevation: 0,
                    color: Colors.white, // Fondo blanco para las tarjetas
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Tarjetas más delgadas
                    child: Padding(
                      padding: EdgeInsets.all(5), // Ajustar padding para hacer las tarjetas más delgadas
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0), // Redondear bordes de las imágenes
                              child: Image.network(
                                item['foto_producto'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              item['nombre_producto'],
                              style: TextStyle(fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'X${item['cantidad']}',
                              style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            trailing: Text('COP ${item['total_pagar']}'),
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
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
