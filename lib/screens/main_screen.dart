import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'products_screen.dart';
import 'wallet_screen.dart';
import 'orders_screen.dart';
import 'admin_dashboard.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final String adminUid = '6LFUmRCvHYWLk9jhcJQgac3cydq1';
  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();

    final isAdmin = FirebaseAuth.instance.currentUser?.uid == adminUid;

    _screens = [
      ProductsScreen(),
      WalletScreen(),
      OrdersScreen(),
    ];

    _navItems = [
      BottomNavigationBarItem(icon: Icon(Icons.store), label: 'المنتجات'),
      BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'طلباتي'),
    ];

    if (isAdmin) {
      _screens.add(AdminDashboard());
      _navItems.add(
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'الإدارة'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: _navItems,
      ),
    );
  }
}
