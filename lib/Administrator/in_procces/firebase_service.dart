import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDocumentFields() async {
    DocumentReference docRef = _firestore
        .doc('/Orderly/Stores/Stores/WOLFSGROUP SAS/compras/compras');

    DocumentSnapshot docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>?;
    } else {
      return null;
    }
  }

  Future<void> updateDeliveryStatus(String documentId, String status) async {
    if (documentId.isNotEmpty) {
      DocumentReference docRef = _firestore
          .doc('/Orderly/Stores/Stores/WOLFSGROUP SAS/compras/compras');
      await docRef.update({'delivery_status': status});
    }
  }
}
