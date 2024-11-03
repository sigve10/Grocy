import 'package:flutter/material.dart';

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

  Widget getActivePage() {
    switch (_selectedPageIndex) {
      case 0:
        // Scan barcode screen
        return const Column();
      case 1:
        // Product-list Screen
        return const Column();
      case 2:
        // Wishlist Screen
        return const Column();
    }

    // Error screen, perchance?
    return const Column();
  }

  void _setScreen(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getActivePage(),
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