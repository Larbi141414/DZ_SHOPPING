import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> productData;
  final String productId;

  ProductDetailsScreen({required this.productData, required this.productId});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void placeOrder(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final balance = userDoc['balance']?.toDouble() ?? 0.0;
    final price = productData['price']?.toDouble() ?? 0.0;

    if (balance >= price) {
      // خصم الرصيد
      await _db.collection('users').doc(user.uid).update({
        'balance': balance - price,
      });

      // إنشاء الطلب
      await _db.collection('orders').add({
        'userId': user.uid,
        'productId': productId,
        'price': price,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم الطلب بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ لا يوجد رصيد كافي')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = productData['name'] ?? 'منتج';
    final String description = productData['description'] ?? '';
    final double price = productData['price']?.toDouble() ?? 0.0;
    final String imageUrl = productData['image'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('السعر: \$${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text(description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.shopping_cart),
                label: Text('طلب المنتج'),
                onPressed: () => placeOrder(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
