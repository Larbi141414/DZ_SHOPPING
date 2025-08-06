import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ UID الأدمن الذي يملك صلاحية الدخول
  final String adminUid = '3bH26n7Y0mRekY6hXsBzpVQadGE3';

  void updateUserBalance(String userId, double newBalance, BuildContext context) async {
    await _db.collection('users').doc(userId).update({'balance': newBalance});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تم تحديث الرصيد')));
  }

  void approveTopUp(String requestId, String userId, double amount, BuildContext context) async {
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final currentBalance = userDoc['balance']?.toDouble() ?? 0.0;

    await userRef.update({'balance': currentBalance + amount});
    await _db.collection('topup_requests').doc(requestId).update({'status': 'approved'});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تمت الموافقة على الشحن')));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    // ✅ التحقق من صلاحية الدخول
    if (currentUser == null || currentUser.uid != adminUid) {
      return Scaffold(
        appBar: AppBar(title: Text('غير مصرح')),
        body: Center(child: Text('🚫 ليس لديك صلاحية الوصول إلى لوحة التحكم')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('لوحة تحكم الأدمن')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📥 طلبات شحن الرصيد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _db.collection('topup_requests').where('status', isEqualTo: 'pending').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final requests = snapshot.data!.docs;
                if (requests.isEmpty) return Text('لا توجد طلبات حالياً.');

                return Column(
                  children: requests.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = data['amount']?.toDouble() ?? 0.0;
                    return Card(
                      child: ListTile(
                        title: Text('🧑 المستخدم: ${data['userId']}'),
                        subtitle: Text('💰 المبلغ المطلوب: \$${amount.toStringAsFixed(2)}'),
                        trailing: ElevatedButton(
                          child: Text('قبول'),
                          onPressed: () => approveTopUp(doc.id, data['userId'], amount, context),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            Divider(height: 40),
            Text('👥 المستخدمون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _db.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final users = snapshot.data!.docs;
                return Column(
                  children: users.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final userId = doc.id;
                    final balance = data['balance']?.toDouble() ?? 0.0;
                    final controller = TextEditingController(text: balance.toString());

                    return Card(
                      child: ListTile(
                        title: Text('ID: $userId'),
                        subtitle: Row(
                          children: [
                            Text('الرصيد:'),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            final newBalance = double.tryParse(controller.text) ?? balance;
                            updateUserBalance(userId, newBalance, context);
                          },
                          child: Text('تحديث'),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
