import 'package:flutter/material.dart';
import 'package:grocy/screens/barcode_scan_screen.dart';
import 'package:grocy/screens/product_list.dart';
import 'package:grocy/screens/wishlist_screen.dart';

class TabsContainerScreen extends StatefulWidget {
  const TabsContainerScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TabsContainerScreenState();
  }
}

class _TabsContainerScreenState extends State<TabsContainerScreen> {
  // Home page
  int _selectedPageIndex = 1;

  final Map<int, Widget> pages = {
    0: const BarcodeScanScreen(),
    1: const ProductList(),
    2: const WishlistScreen()
  };

  final Map<int, GlobalKey<NavigatorState>> navKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>()
  };

  Widget getActivePage() {
    return Navigator(
      key: navKeys[_selectedPageIndex],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => pages[_selectedPageIndex] ?? const Column()
        );
      },
    );
  }

  void _setScreen(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => getActivePage()
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _setScreen,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_sharp),
            label: "Scan barcode"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Wishlist"
          )
        ]
      ),
    );
  }
}