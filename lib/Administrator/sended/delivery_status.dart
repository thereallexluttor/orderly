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
        title: const Text('Delivery Status'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
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
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Details',
                            style: Theme.of(context).textTheme.headline5?.copyWith(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selected Key: ${widget.selectedKey}',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(
                            'Parent Document ID: ${widget.parentDocumentId}',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: data['delivery_status'] == 'en proceso' ? null : updateDeliveryStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                            child: const Text('Change Status to "En Proceso"'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = data.entries.elementAt(index);
                          return _buildGridItem(context, entry);
                        },
                        childCount: data.length,
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, MapEntry<String, dynamic> entry) {
    if (entry.key == 'foto_producto' && entry.value is String) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            entry.value,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red),
          ),
        ),
      );
    } else {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.label,
                color: Colors.teal,
              ),
              const SizedBox(height: 8),
              Text(
                entry.key,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  '${entry.value}',
                  style: Theme.of(context).textTheme.bodyText2,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
