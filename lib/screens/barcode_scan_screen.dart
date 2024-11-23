import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/screens/create_product_screen.dart';
import 'package:grocy/screens/product_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grocy/extentions/snackbar_context.dart';

import '../models/product.dart';
import '../provider/product_provider.dart';

/// A screen that scans a barcode and fetches the product from the backend.
class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BarcodeScanScreenState();
}

/// Manages the state of the barcode scanner screen. It listens to barcode events
/// and fetches the product from the backend. When the product is fetched, it
/// navigates to either the product screen or the create product screen.
class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.ean13],
    autoStart: true,
  );

  late final ProductProvider _productProvider;
  bool isFetching = false;
  StreamSubscription<Object?>? _subscription;

  final supabase = Supabase.instance.client;

  /// Handles the barcode event, by fetching the product from backend.
  void _handleBarcode(BarcodeCapture barcode) {
    if (mounted) {
      final detectedBarcode = barcode.barcodes.firstOrNull;

      if (detectedBarcode != null &&
          detectedBarcode.displayValue != null &&
          isFetching == false) {
        setState(() {
          isFetching = true;
        });

        fetchAndDisplayProduct(detectedBarcode.displayValue!)
            .whenComplete(() => setState(() => isFetching = false));
      }
    }
  }

  /// Fetches a product from the database and displays it.
  Future<void> fetchAndDisplayProduct(String barcode) async {
    try {
      Product product = await _productProvider.fetchProduct(barcode, context);
      if (product.primaryTag == null) {
        if (mounted) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateProductScreen(
                        product: product,
                      )));
        }
      } else {
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(product: product),
            ),
          );
        }
      }
    } catch (e) {
      if (e is FunctionException) {
        if (mounted) context.showSnackBar(e.details['error']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _productProvider = ref.read(productProvider.notifier);
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
