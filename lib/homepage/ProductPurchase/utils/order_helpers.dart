import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const kAnimationDuration = Duration(milliseconds: 300);
const kConfettiDuration = Duration(seconds: 1);

int calculateTotal(int price, int discount, int quantity) {
  double discountedPrice = price * ((100 - discount) / 100);
  return (discountedPrice * quantity).round();
}

Map<String, dynamic> buildOrderData(Map<String, dynamic> itemData, int quantity) {
  String fechaActual = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  int totalPagar = (itemData['precio'] * ((100 - itemData['discount']) / 100)).round() * quantity;

  return {
    'nombre_producto': itemData['nombre'],
    'precio': (itemData['precio'] * ((100 - itemData['discount']) / 100)).round(),
    'cantidad': quantity,
    'ruta': itemData['ruta'],
    'foto_producto': itemData['foto_producto'],
    'total_pagar': totalPagar,
    'ruta_carrito': '${itemData['ruta']}/carritos/carritos',
    'fecha': fechaActual,
    'status': 'sin pagar',
    'delivery_status': 'no',
  };
}

Future<void> saveToCarrito(Map<String, dynamic> itemData, Map<String, dynamic> orderData, String userId) async {
  DocumentReference cartRef = FirebaseFirestore.instance.doc('${itemData['ruta']}/carritos/carritos');
  DocumentSnapshot cartSnapshot = await cartRef.get();

  Map<String, dynamic> cartData = cartSnapshot.exists
      ? Map<String, dynamic>.from(cartSnapshot.data() as Map)
      : {};

  String uniqueId = Uuid().v4();
  Map<String, dynamic> userCart = Map<String, dynamic>.from(cartData[userId] ?? {});
  userCart[uniqueId] = orderData;
  cartData[userId] = userCart;

  await cartRef.set(cartData);
}

Future<void> saveToUserCollection(Map<String, dynamic> orderData, String userId) async {
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('Orderly').doc('Users').collection('users').doc(userId);
  DocumentSnapshot userDocSnapshot = await userDocRef.get();

  Map<String, dynamic> carritoCompraData = userDocSnapshot.exists
      ? Map<String, dynamic>.from(userDocSnapshot.data() as Map)
      : {};

  String uniqueId = Uuid().v4();
  Map<String, dynamic> userCarritoCompra = Map<String, dynamic>.from(carritoCompraData['carrito_compra'] ?? {});
  userCarritoCompra[uniqueId] = orderData;
  carritoCompraData['carrito_compra'] = userCarritoCompra;

  await userDocRef.set(carritoCompraData, SetOptions(merge: true));
}
