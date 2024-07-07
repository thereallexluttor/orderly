import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Shopping_Cart extends StatelessWidget {
  const Shopping_Cart({super.key});

  Future<Map<String, dynamic>?> _fetchCartData() async {
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
        title: Text('Tu carrito de compras. 🛒👀🧐', 
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 13),
          ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchCartData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No se encontraron datos del carrito.'));
          }

          Map<String, dynamic> cartData = snapshot.data!['carrito_compra'] ?? {};
          if (cartData.isEmpty) {
            return Center(child: Text('El carrito está vacío.'));
          }

          return ListView.builder(
            itemCount: cartData.length,
            itemBuilder: (context, index) {
              String key = cartData.keys.elementAt(index);
              Map<String, dynamic> item = cartData[key];

              return ListTile(
                leading: Image.network(item['foto_producto']),
                title: Text(
                  item['nombre_producto'],
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 11
                  ),),
                subtitle: Text('X${item['cantidad']}', 
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
                  ),
                trailing: Text('COP ${item['total_pagar']}'),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Shopping_Cart(),
  ));
}
