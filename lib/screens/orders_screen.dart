import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Center(child: Text('يرجى تسجيل الدخول لعرض الطلبات.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('طلباتي'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(child: Text('لم تقم بأي طلبات بعد.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final productId = data['productId'] ?? '';
              final price = data['price']?.toDouble() ?? 0.0;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text('معرّف المنتج: $productId'),
                  subtitle: Text('السعر: \$${price.toStringAsFixed(2)}'),
                  trailing: Text(
                    timestamp != null
                        ? '${timestamp.day}/${timestamp.month}/${timestamp.year}'
                        : '',
                    style: TextStyle(fontSize: 12),
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
