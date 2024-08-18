import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getDocumentStream() {
    return _firestore.collection('your_collection').doc('your_document_id').snapshots();
  }

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
