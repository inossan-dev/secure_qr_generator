import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';

/// Widget that automatically handles QR code regeneration
/// before expiration to ensure service continuity.
class AutoRegeneratingQRView extends StatefulWidget {
  /// Data to be encoded in the QR code
  final QRData data;

  /// QR code generator to use
  final SecureQRGenerator generator;

  /// Interval between regenerations
  /// Default: 80% of the configured validity duration
  final Duration? regenerationInterval;

  /// Callback called on each regeneration
  final void Function(GenerationResult)? onRegenerate;

  /// Callback called in case of error
  final void Function(dynamic)? onError;

  /// Optional function allowing complete customization of the QR code rendering.
  /// If not provided, the widget will use QrImageView by default.
  ///
  /// The qrData parameter contains the encoded and secured data ready
  /// to be displayed.
  final Widget Function(String qrData)? builder;

  /// QR code style
  final QrStyle style;

  /// QR code size
  final double size;

  const AutoRegeneratingQRView({
    super.key,
    required this.data,
    required this.generator,
    this.regenerationInterval,
    this.onRegenerate,
    this.onError,
    this.builder,
    this.style = const QrStyle(
      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square),
      dataModuleStyle:
          QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle),
    ),
    this.size = 200,
  });

  @override
  State<AutoRegeneratingQRView> createState() => _AutoRegeneratingQRViewState();
}

class _AutoRegeneratingQRViewState extends State<AutoRegeneratingQRView> {
  Timer? _regenerationTimer;
  GenerationResult? _currentResult;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateInitialQR();
  }

  @override
  void dispose() {
    _regenerationTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(AutoRegeneratingQRView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _generateInitialQR();
    }
  }

  Future<void> _generateInitialQR() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.generator.generateQR(widget.data);
      _startRegenerationTimer();

      setState(() {
        _currentResult = result;
        _isLoading = false;
      });

      widget.onRegenerate?.call(result);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      widget.onError?.call(e);
    }
  }

  void _startRegenerationTimer() {
    _regenerationTimer?.cancel();

    // Calculate regeneration interval
    final interval = widget.regenerationInterval ??
        Duration(
          milliseconds:
              (widget.generator.config.validityDuration.inMilliseconds * 0.8)
                  .round(),
        );

    _regenerationTimer = Timer.periodic(interval, (_) => _regenerateQR());
  }

  Future<void> _regenerateQR() async {
    try {
      final result = await widget.generator.generateQR(widget.data);

      setState(() {
        _currentResult = result;
        _error = null;
      });

      widget.onRegenerate?.call(result);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      widget.onError?.call(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Text(
            'Error: $_error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (_currentResult == null) {
      return const SizedBox.shrink();
    }

    return widget.builder?.call(_currentResult!.qrContent) ??
        QrImageView(
          data: _currentResult!.qrContent,
          size: widget.size,
          eyeStyle: widget.style.eyeStyle ??
              const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
          dataModuleStyle: widget.style.dataModuleStyle ??
              const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
          embeddedImage: widget.style.embeddedImage,
          embeddedImageStyle: widget.style.embeddedImageStyle,
        );
  }
}

/// Style for customizing QR code appearance
class QrStyle {
  final QrEyeStyle? eyeStyle;
  final QrDataModuleStyle? dataModuleStyle;
  final ImageProvider? embeddedImage;
  final QrEmbeddedImageStyle? embeddedImageStyle;

  const QrStyle({
    this.eyeStyle,
    this.dataModuleStyle,
    this.embeddedImage,
    this.embeddedImageStyle,
  });
}
