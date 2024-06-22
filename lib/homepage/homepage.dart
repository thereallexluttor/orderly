// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:orderly/homepage/product_category/category_buttons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CategoryButton(
                  imagePath: 'lib/images/product_category/motos_y_autopartes.png',
                  label: 'motos y autopartes',
                ),
                SizedBox(width: 10,),
                CategoryButton(
                  imagePath: 'lib/images/product_category/moda_y_accesorios.png',
                  label: 'Moda y accesorios',
                ),
                SizedBox(width: 10,),
                CategoryButton(
                  imagePath: 'lib/images/product_category/deportes_y_hobbies.png',
                  label: 'deportes y hobbies',
                ),
                SizedBox(width: 10,),
                CategoryButton(
                  imagePath: 'lib/images/product_category/electronica_de_consumo.png',
                  label: 'electronica de consumo',
                ),
                SizedBox(width: 10,),
                CategoryButton(
                  imagePath: 'lib/images/product_category/hogar_y_accesorios.png',
                  label: 'Hogar y accesorios',
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}