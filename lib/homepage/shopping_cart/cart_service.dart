import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> fetchCartData() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentReference userDocRef = _firestore
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

  Future<void> deleteItemFromCart(String itemKey, Map<String, dynamic> item) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String rutaCarrito = item['ruta_carrito'];

    DocumentReference cartRef = _firestore.doc(rutaCarrito);
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

    DocumentReference userDocRef = _firestore
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(user.uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      Map<String, dynamic> carritoCompraData = Map<String, dynamic>.from(userDocSnapshot.data() as Map);
      if (carritoCompraData.containsKey('carrito_compra')) {
        Map<String, dynamic> userCarritoCompra = Map<String, dynamic>.from(carritoCompraData['carrito_compra']);

        String? keyToRemove;
        userCarritoCompra.forEach((key, value) {
          if (value['nombre_producto'] == item['nombre_producto'] &&
              value['cantidad'] == item['cantidad'] &&
              value['total_pagar'] == item['total_pagar']) {
            keyToRemove = key;
          }
        });

        if (keyToRemove != null) {
          userCarritoCompra.remove(keyToRemove);
          carritoCompraData['carrito_compra'] = userCarritoCompra;
          await userDocRef.set(carritoCompraData);
        }
      }
    }
  }

  Future<void> completePurchase(ConfettiController confettiController) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentReference userDocRef = _firestore
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(user.uid);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      Map<String, dynamic> carritoCompraData = Map<String, dynamic>.from(userDocSnapshot.data() as Map);
      Map<String, dynamic> carritoCompra = Map<String, dynamic>.from(carritoCompraData['carrito_compra'] ?? {});
      Map<String, dynamic> compras = Map<String, dynamic>.from(carritoCompraData['compras'] ?? {});

      String fechaCompra = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      WriteBatch batch = _firestore.batch();

      carritoCompra.forEach((key, value) {
        value['status'] = 'pagado';
        value['fecha_compra'] = fechaCompra;
        value['delivery_status'] = value['delivery_status'] ?? 'no';
        compras[key] = value;

        String rutaCarrito = value['ruta_carrito'];
        DocumentReference cartRef = _firestore.doc(rutaCarrito);
        batch.update(cartRef, {
          '${user.uid}.$key': FieldValue.delete()
        });

        batch.update(userDocRef, {
          'carrito_compra.$key': FieldValue.delete()
        });
      });

      carritoCompraData['compras'] = compras;
      carritoCompraData.remove('carrito_compra');

      batch.set(userDocRef, carritoCompraData);

      DocumentReference compraRef = _firestore
          .collection('Orderly')
          .doc('Stores')
          .collection('Stores')
          .doc('WOLFSGROUP SAS')
          .collection('compras')
          .doc('compras');

      batch.set(compraRef, {
        user.uid: compras
      });

      await batch.commit();
    }

    confettiController.play();
  }
}
