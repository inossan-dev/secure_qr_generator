import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';

/// Widget qui gère automatiquement la régénération des QR codes
/// avant leur expiration pour assurer une continuité de service.
class AutoRegeneratingQR extends StatefulWidget {
  /// Données à encoder dans le QR code
  final QRData data;

  /// Générateur de QR codes à utiliser
  final SecureQRGenerator generator;

  /// Intervalle entre les régénérations
  /// Par défaut : 80% de la durée de validité configurée
  final Duration? regenerationInterval;

  /// Callback appelé à chaque régénération
  final void Function(GenerationResult)? onRegenerate;

  /// Callback appelé en cas d'erreur
  final void Function(dynamic)? onError;

  /// Optional function allowing complete customization of the QR code rendering.
  /// If not provided, the widget will use QrImageView by default.
  ///
  /// The qrData parameter contains the encoded and secured data ready
  /// to be displayed.
  final Widget Function(String qrData)? builder;

  /// Style du QR code
  final QrStyle style;

  /// Taille du QR code
  final double size;

  const AutoRegeneratingQR({
    super.key,
    required this.data,
    required this.generator,
    this.regenerationInterval,
    this.onRegenerate,
    this.onError,
    this.builder,
    this.style = const QrStyle(),
    this.size = 200,
  });

  @override
  State<AutoRegeneratingQR> createState() => _AutoRegeneratingQRState();
}

class _AutoRegeneratingQRState extends State<AutoRegeneratingQR> {
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
  void didUpdateWidget(AutoRegeneratingQR oldWidget) {
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

    // Calcul de l'intervalle de régénération
    final interval = widget.regenerationInterval ??
        Duration(
          milliseconds: (widget.generator.config.validityDuration.inMilliseconds * 0.8).round(),
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
            'Erreur: $_error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (_currentResult == null) {
      return const SizedBox.shrink();
    }

    return widget.builder?.call(_currentResult!.qrContent) ?? QrImageView(
      data: _currentResult!.qrContent,
      size: widget.size,
      eyeStyle: widget.style.eyeStyle ?? const QrEyeStyle(),
      dataModuleStyle: widget.style.dataModuleStyle ?? const QrDataModuleStyle(),
      embeddedImage: widget.style.embeddedImage,
      embeddedImageStyle: widget.style.embeddedImageStyle,
    );
  }
}

/// Style pour personnaliser l'apparence du QR code
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