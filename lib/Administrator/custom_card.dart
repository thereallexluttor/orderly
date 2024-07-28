import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderly/Administrator/nested_list.dart';

class CustomCard extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> value;
  final VoidCallback onTap;
  final String parentId;

  const CustomCard({
    required this.documentId,
    required this.value,
    required this.onTap,
    required this.parentId,
    Key? key,
  }) : super(key: key);

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  Future<Map<String, dynamic>?> getUserData(String parentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Orderly/Users/users')
          .doc(parentId)
          .get();

      return snapshot.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(widget.parentId),
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.waiting) {
          child = Center();
        } else if (snapshot.hasError) {
          child = Text('Error loading user data');
        } else if (snapshot.hasData) {
          final userData = snapshot.data;
          final userName = userData?['name'] ?? 'No name';
          final userPhoto = userData?['photo'] ?? '';

          child = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.parentId,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  fontFamily: "Poppins",
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (userPhoto.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: NetworkImage(userPhoto),
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      onBackgroundImageError: (_, __) => Icon(Icons.image, size: 30),
                    ),
                  const SizedBox(width: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Poppins",
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: widget.onTap,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.value.containsKey('foto_producto') && widget.value['foto_producto'] is String)
                      const SizedBox(height: 0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 0),
                          NestedList(data: widget.value, documentId: widget.documentId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          child = Text('No user data available');
        }

        return AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(seconds: 0),
          child: Card(
            surfaceTintColor: Color.fromARGB(255, 255, 255, 255),
            color: Color.fromARGB(255, 255, 255, 255),
            margin: const EdgeInsets.all(10),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 255, 240, 255)),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10.0),
              child: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
