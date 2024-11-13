import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> with WidgetsBindingObserver {

  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.all],
    autoStart: true,
  );
  Barcode? _barcode;
  StreamSubscription<Object?>? _subscription;

  void _handleBarcode(BarcodeCapture barcode) {
    if (mounted) {
      print('Barcode detected: ${barcode.barcodes.firstOrNull}');
      setState(() {
        _barcode = barcode.barcodes.firstOrNull;
      });
    }
  }

  Widget _buildBarcode(Barcode? barcode) {
    if (barcode == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      barcode.displayValue ?? 'No display value.',
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
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
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
