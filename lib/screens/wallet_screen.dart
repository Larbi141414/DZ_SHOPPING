import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _amountController = TextEditingController();

  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  void _loadBalance() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      setState(() {
        _balance = doc['balance']?.toDouble() ?? 0.0;
      });
    }
  }

  void _submitTopUpRequest() async {
    final user = _auth.currentUser;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (user != null && amount > 0) {
      await _db.collection('topup_requests').add({
        'userId': user.uid,
        'amount': amount,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم إرسال طلب الشحن. في انتظار الموافقة')),
      );

      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('💳 المحفظة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('رصيدك الحالي', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('\$${_balance.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Divider(height: 32),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'أدخل المبلغ لشحن الرصيد'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitTopUpRequest,
              child: Text('طلب شحن'),
            ),
            SizedBox(height: 32),
            Text('💡 للدفع استخدم BaridiMob ثم أرسل لقطة شاشة للإدارة'),
          ],
        ),
      ),
    );
  }
}
