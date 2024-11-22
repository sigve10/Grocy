import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocy/screens/create_product_screen.dart';
import 'package:grocy/screens/product_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grocy/extentions/snackbar_context.dart';

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
  bool isFetching = false;
  StreamSubscription<Object?>? _subscription;

  final supabase = Supabase.instance.client;

  void _handleBarcode(BarcodeCapture barcode) {
    if (mounted) {
      final detectedBarcode = barcode.barcodes.firstOrNull;

      print('Barcode detected: $detectedBarcode');

      if (detectedBarcode != null &&
          detectedBarcode.displayValue != null &&
          isFetching == false) {
        setState(() {
          isFetching = true;
          _barcode = detectedBarcode;
        });

        fetchProduct(detectedBarcode.displayValue!)
            .whenComplete(() => setState(() => isFetching = false));
      }
    }
  }

  Future<void> fetchProduct(String barcode) async {
    print("Fetching product with barcode: $barcode");

    try {
      final res = await supabase.functions.invoke("fetch-product",
          body: {"ean": barcode},
          headers: {"Content-Type": "application/json"},
          method: HttpMethod.post);

      final productJson = res.data as Map<String, dynamic>;
      Product product = Product.fromJson(productJson);

      if (product.ean.isEmpty) {
        if (mounted) context.showSnackBar("Error parsing product");
        return;
      }

      if (product.primaryTag == null) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateProductScreen(
                      product: product,
                    )));
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: product),
          ),
        );
      }
    } catch (e) {
      if (e is FunctionException) {
        print(e.details);
        if (mounted) context.showSnackBar(e.details['error']);
      }
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
        alignment: Alignment.center,
        child: isFetching
            ? Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const CircularProgressIndicator(),
              )
            : null,
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
