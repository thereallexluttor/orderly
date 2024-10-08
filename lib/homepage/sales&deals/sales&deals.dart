// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:orderly/homepage/StoreHomePage/StoreHomePage.dart';
import 'dart:math' as math;
import 'package:orderly/homepage/sales&deals/itemcard.dart';

class StoreCard extends StatefulWidget {
  final Map<String, dynamic> storeData;
  final DocumentReference storeReference;

  const StoreCard({
    super.key,
    required this.storeData,
    required this.storeReference,
  });

  @override
  _StoreCardState createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  double? currentLatitude;
  double? currentLongitude;
  List<Map<String, dynamic>> storeItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _fetchItems().then((items) {
      setState(() {
        storeItems = items;
        isLoading = false;
      });
    });
  }

  Future<void> _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      currentLatitude = locationData.latitude;
      currentLongitude = locationData.longitude;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    final itemsCollection = widget.storeReference.collection('items');

    // Primero intentamos obtener los datos de la caché
    final snapshot = await itemsCollection.get(GetOptions(source: Source.cache));

    if (snapshot.docs.isEmpty) {
      // Si la caché está vacía, obtenemos los datos del servidor
      final serverSnapshot = await itemsCollection.get(GetOptions(source: Source.server));
      List<Map<String, dynamic>> items = serverSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      items.sort((a, b) => (b['ventas'] ?? 0).compareTo(a['ventas'] ?? 0));
      return items.take(10).toList();
    } else {
      List<Map<String, dynamic>> items = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      items.sort((a, b) => (b['ventas'] ?? 0).compareTo(a['ventas'] ?? 0));
      return items.take(10).toList();
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (math.pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    final storeLatitude = widget.storeData['gps_point']?.latitude;
    final storeLongitude = widget.storeData['gps_point']?.longitude;
    final distance = (currentLatitude != null && currentLongitude != null && storeLatitude != null && storeLongitude != null)
        ? _calculateDistance(currentLatitude!, currentLongitude!, storeLatitude, storeLongitude)
        : null;

    return GestureDetector(
     onTap: () {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => StoreHomePage(
        storeData: widget.storeData,
        storeReference: widget.storeReference,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 800), // Ajusta la duración aquí
    ),
  );
},

      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      widget.storeData['logo'] ?? '',
                      height: 35,
                      width: 35,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.store, size: 50);
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.storeData['nombre'] ?? 'Unnamed Store',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${widget.storeData['ciudad'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                            ),
                            SizedBox(width: 8),
                            if (distance != null)
                              Text(
                                '(${distance.toStringAsFixed(2)} km. 📍)',
                                style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "Poppins"),
                              ),
                            SizedBox(width: 50),
                            Row(
                              children: [
                                Text(
                                  '⭐',
                                  style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${widget.storeData['stars'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '❤️',
                                  style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${widget.storeData['numero_ventas'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...storeItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              child: ItemCard(itemData: item),
                            );
                          }).toList(),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Acción a realizar cuando se presione el círculo
                                  print(widget.storeData['nombre']);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 20,
                                  height: 20,
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ver más',
                                style: TextStyle(fontSize: 10, color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
