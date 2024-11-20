import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocy/screens/create_product_screen.dart';
import 'package:grocy/screens/product_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.ean13],
    autoStart: true,
  );
  Barcode? _barcode;
  bool isTryFetch = false;
  StreamSubscription<Object?>? _subscription;

  final supabase = Supabase.instance.client;

  void _handleBarcode(BarcodeCapture barcode) {
    if (mounted) {
      final detectedBarcode = barcode.barcodes.firstOrNull;

      print('Barcode detected: $detectedBarcode');

      if (detectedBarcode != null && detectedBarcode.displayValue != null && isTryFetch == false) {
        isTryFetch = true;
        setState(() {
          _barcode = detectedBarcode;
        });

        fetchProduct(detectedBarcode.displayValue!)
          .whenComplete(() => isTryFetch = false);
      }
    }
  }

  Future<void> fetchProduct(String barcode) async {
    print("Fetching product with barcode: $barcode");
    final res = await supabase.functions.invoke("fetch-product",
        body: {"ean": barcode},
        headers: {"Content-Type": "application/json"},
        method: HttpMethod.post);

    if (res.status == 200 && res.data != null) {
      final productJson = res.data as Map<String, dynamic>;
      Product product = Product.fromJson(productJson);

      if (product.ean.isEmpty) {
        print("Product not found");
        return;
      }

      if (product.primaryTag == null) {
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => CreateProductScreen(product: product,)));
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: product),
          ),
        );
      }
    } else {
      print("Error: " + res.data);
    }
  }

  Widget _buildBarcode(Barcode? barcode) {
    return Text(
      barcode?.displayValue ?? 'Scan something',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _subscription = controller.barcodes.listen(_handleBarcode);

    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MobileScanner(
        fit: BoxFit.contain,
        scanWindow: Rect.fromCenter(
          center: MediaQuery.sizeOf(context).center(Offset.zero),
          width: 200,
          height: 200,
        ),
        errorBuilder: (context, error, child) {
          return const Center(
            child: Text(
              'An error occurred while initializing the camera.',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
        controller: controller,
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            alignment: Alignment.bottomCenter,
            height: 100,
            color: Colors.black.withOpacity(0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: Center(child: _buildBarcode(_barcode)))
              ],
            )),
      )
    ]);
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }
}
