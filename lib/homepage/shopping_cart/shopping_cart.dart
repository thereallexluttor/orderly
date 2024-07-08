// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Shopping_Cart extends StatefulWidget {
  const Shopping_Cart({super.key});

  @override
  _Shopping_CartState createState() => _Shopping_CartState();
}

class _Shopping_CartState extends State<Shopping_Cart> {
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

  Future<void> _deleteItemFromCart(String itemKey, Map<String, dynamic> item) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String rutaCarrito = item['ruta_carrito'];

    // Eliminar el producto del documento de Firestore en la ruta especificada
    DocumentReference cartRef = FirebaseFirestore.instance.doc(rutaCarrito);
    DocumentSnapshot cartSnapshot = await cartRef.get();
    if (cartSnapshot.exists) {
      Map<String, dynamic> cartData = Map<String, dynamic>.from(cartSnapshot.data() as Map);
      if (cartData.containsKey(user.uid)) {
        Map<String, dynamic> userCart = Map<String, dynamic>.from(cartData[user.uid]);
        if (userCart.containsKey(itemKey)) {
          userCart.remove(itemKey);
          cartData[user.uid] = userCart;
          await cartRef.set(cartData);
        }
      }
    }

    // Eliminar el producto del carrito de compras del usuario en la colección 'Orderly/Users/users/{user.uid}'
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(user.uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      Map<String, dynamic> carritoCompraData = Map<String, dynamic>.from(userDocSnapshot.data() as Map);
      if (carritoCompraData.containsKey('carrito_compra')) {
        Map<String, dynamic> userCarritoCompra = Map<String, dynamic>.from(carritoCompraData['carrito_compra']);
        print(userCarritoCompra);
        
        // Encontrar la clave del elemento a eliminar
        String? keyToRemove;
        userCarritoCompra.forEach((key, value) {
          print(key);
         
          if (value['nombre_producto'] == item['nombre_producto'] &&
              value['cantidad'] == item['cantidad'] &&
              value['total_pagar'] == item['total_pagar']) {
            keyToRemove = key;
          }
        });

        // Eliminar el elemento si se encuentra
        if (keyToRemove != null) {
          print('Eliminando elemento con clave: $keyToRemove');
          userCarritoCompra.remove(keyToRemove);
          print(userCarritoCompra);
          carritoCompraData['carrito_compra'] = userCarritoCompra;
          await userDocRef.set(carritoCompraData);
        } else {
          print('No se encontró el elemento a eliminar.');
        }
      } else {
        print('carrito_compra no encontrado en los datos del usuario.');
      }
    } else {
      print('No se encontró el documento del usuario.');
    }

    // Actualizar la interfaz de usuario
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tu carrito de compras. 🛒👀🧐',
          style: TextStyle(fontFamily: "Poppins", fontSize: 13),
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

              return Dismissible(
                key: Key(key),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await _deleteItemFromCart(key, item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['nombre_producto']} eliminado del carrito')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  leading: Image.network(item['foto_producto']),
                  title: Text(
                    item['nombre_producto'],
                    style: TextStyle(fontFamily: "Poppins", fontSize: 11),
                  ),
                  subtitle: Text(
                    'X${item['cantidad']}',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  trailing: Text('COP ${item['total_pagar']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
