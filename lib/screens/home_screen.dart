import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  double userBalance = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUserBalance();
  }

  Future<void> fetchUserBalance() async {
    final uid = _auth.currentUser!.uid;
    final userDoc = await _db.collection('users').doc(uid).get();
    setState(() {
      userBalance = userDoc['balance']?.toDouble() ?? 0.0;
    });
  }

  Future<void> orderProduct(Product product) async {
    final uid = _auth.currentUser!.uid;

    if (userBalance >= product.price) {
      // خصم الرصيد
      await _db.collection('users').doc(uid).update({
        'balance': FieldValue.increment(-product.price),
      });

      // حفظ الطلب
      await _db.collection('orders').add({
        'userId': uid,
        'productId': product.id,
        'productName': product.name,
        'price': product.price,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم طلب المنتج بنجاح!')),
      );

      fetchUserBalance(); // تحديث الرصيد
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رصيدك غير كافٍ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المنتجات'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(child: Text('الرصيد: \$${userBalance.toStringAsFixed(2)}')),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final products = snapshot.data!.docs.map((doc) {
            return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(product.name),
                  subtitle: Text('السعر: \$${product.price.toStringAsFixed(2)}'),
                  trailing: ElevatedButton(
                    child: Text('طلب'),
                    onPressed: () => orderProduct(product),
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
