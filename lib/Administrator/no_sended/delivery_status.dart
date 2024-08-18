import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryStatusPage extends StatefulWidget {
  final String selectedKey;
  final String parentDocumentId;

  const DeliveryStatusPage({
    required this.selectedKey,
    required this.parentDocumentId,
    Key? key,
  }) : super(key: key);

  @override
  _DeliveryStatusPageState createState() => _DeliveryStatusPageState();
}

class _DeliveryStatusPageState extends State<DeliveryStatusPage> {
  late Future<Map<String, dynamic>?> _documentData;

  @override
  void initState() {
    super.initState();
    _documentData = fetchDocumentData();
  }

  Future<Map<String, dynamic>?> fetchDocumentData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .doc('/Orderly/Stores/Stores/WOLFSGROUP SAS/compras/compras')
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey(widget.parentDocumentId)) {
          Map<String, dynamic> parentMap = data[widget.parentDocumentId] as Map<String, dynamic>;

          if (parentMap.containsKey(widget.selectedKey)) {
            return parentMap[widget.selectedKey] as Map<String, dynamic>;
          } else {
            print('Selected key not found in parent map.');
            return null;
          }
        } else {
          print('Parent document ID not found in main map.');
          return null;
        }
      } else {
        print('Document does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching document: $e');
      return null;
    }
  }

  Future<void> updateDeliveryStatus() async {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .doc('/Orderly/Stores/Stores/WOLFSGROUP SAS/compras/compras');

      DocumentSnapshot documentSnapshot = await documentReference.get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey(widget.parentDocumentId)) {
          Map<String, dynamic> parentMap = data[widget.parentDocumentId] as Map<String, dynamic>;

          if (parentMap.containsKey(widget.selectedKey)) {
            parentMap[widget.selectedKey]['delivery_status'] = 'en proceso';
            await documentReference.update({
              widget.parentDocumentId: data[widget.parentDocumentId],
            });

            setState(() {
              _documentData = fetchDocumentData();
            });
          }
        }
      }
    } catch (e) {
      print('Error updating delivery status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Status', 
          style: TextStyle(fontFamily: "Poppins", fontSize: 13),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 16, // Tamaño del ícono de volver
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _documentData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data available'));
            } else {
              Map<String, dynamic> data = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 1,
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              if (data.containsKey('foto_producto') && data['foto_producto'] is String)
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(data['foto_producto']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['nombre_producto'],
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildDetailRow('Precio', data['precio']),
                                    _buildDetailRow('Cantidad', data['cantidad']),
                                    _buildDetailRow('Total a pagar', data['total_pagar']),
                                    _buildDetailRow('Status', data['status']),
                                    _buildDetailRow('Delivery status', data['delivery_status']),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: data['delivery_status'] == 'en proceso' ? null : updateDeliveryStatus,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 216, 20, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // esquinas ligeramente redondeadas
                                ),
                              ),
                              child: const Text(
                                'Change Status to "En Proceso"',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
