import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductsScreen extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void placeOrder(String productId, double price, BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final balance = userDoc['balance']?.toDouble() ?? 0.0;

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
    return Scaffold(
      appBar: AppBar(title: Text('🛒 المنتجات')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final products = snapshot.data!.docs;

          if (products.isEmpty) return Center(child: Text('لا توجد منتجات حالياً.'));

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;
              final name = product['name'] ?? 'بدون اسم';
              final price = product['price']?.toDouble() ?? 0.0;
              final imageUrl = product['image'] ?? '';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image),
                  title: Text(name),
                  subtitle: Text('السعر: \$${price.toStringAsFixed(2)}'),
                  trailing: ElevatedButton(
                    onPressed: () => placeOrder(productId, price, context),
                    child: Text('طلب'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
