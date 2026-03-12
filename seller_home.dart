import 'package:flutter/material.dart';

class SellerHome extends StatelessWidget {
  const SellerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Dashboard"),
      ),
      body: const Center(
        child: Text(
          "Welcome Seller",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}