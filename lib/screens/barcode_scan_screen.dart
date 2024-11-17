import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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
    formats: const [BarcodeFormat.all],
    autoStart: true,
  );
  Barcode? _barcode;
  StreamSubscription<Object?>? _subscription;

  final supabase = Supabase.instance.client;

  void _handleBarcode(BarcodeCapture barcode) {
    if (mounted) {
      final detectedBarcode = barcode.barcodes.firstOrNull;

      print('Barcode detected: $detectedBarcode');

      if (detectedBarcode != null && detectedBarcode.displayValue != null) {
        setState(() {
          _barcode = barcode.barcodes.firstOrNull;
        });

        controller.stop();

        fetchProduct(detectedBarcode.displayValue!);
      }
    }
  }

  Future<void> fetchProduct(String barcode) async {
    print("Fetching product with barcode: $barcode");
    final res = await supabase.functions.invoke("fetch-product",
        body: {"ean": barcode},
        headers: {"Content-Type": "application/json"},
        method: HttpMethod.post);

    print(res.data); //temp logging

    if (res.status == 200 && res.data != null) {
      final productJson = res.data as Map<String, dynamic>;
      Product product = Product.fromJson(productJson);

      if (product.ean.isEmpty) {
        print("Product not found");
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductScreen(product: product),
        ),
      );

      if (mounted) await controller.start();
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
    switch (state) {
      case AppLifecycleState.paused:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
        break;
      case AppLifecycleState.resumed:
        if (controller.value.isRunning == false) {
          _subscription = controller.barcodes.listen(_handleBarcode);
          unawaited(controller.start());
        }
        break;
      default:
        break;
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
