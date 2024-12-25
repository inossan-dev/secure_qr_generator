import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure QR Genrator Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const QRDisplayScreen(),
    );
  }
}

class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({super.key});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  late TextEditingController phoneController;
  late TextEditingController secretKeyController;
  bool enableEncryption = true;
  bool enableSignature = true;
  int validityDuration = 60;
  String phoneNumber = '07070707';

  // Configuration
  late GeneratorConfig secureConfig;
  late SecureQRGenerator generator;

  // Mise à jour du générateur
  void updateGenerator() {
    setState(() {
      secureConfig = GeneratorConfig(
        secretKey: secretKeyController.text,
        enableEncryption: enableEncryption,
        enableSignature: enableSignature,
        validityDuration: Duration(seconds: validityDuration),
      );
      generator = SecureQRGenerator(secureConfig);
    });
  }

  @override
  void initState() {
    phoneController = TextEditingController(text: phoneNumber);
    secretKeyController =
        TextEditingController(text: '2024#@#qrcod#orange@##perform#==');
    // Initialisation des configs
    secureConfig = GeneratorConfig(
      secretKey: secretKeyController.text,
      enableEncryption: enableEncryption,
      enableSignature: enableSignature,
      validityDuration: Duration(seconds: validityDuration),
    );
    generator = SecureQRGenerator(secureConfig);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure QR Generator Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: secretKeyController,
              decoration: const InputDecoration(
                  labelText: 'Clé secrète AES-256 (optionnel)'),
              onChanged: (_) => updateGenerator(),
            ),
            SwitchListTile(
              title: const Text('Chiffrement (optionnel)'),
              value: enableEncryption,
              onChanged: (value) {
                setState(() {
                  enableEncryption = value;
                  updateGenerator();
                });
              },
            ),
            SwitchListTile(
              title: const Text('Signature (optionnel)'),
              value: enableSignature,
              onChanged: (value) {
                setState(() {
                  enableSignature = value;
                  updateGenerator();
                });
              },
            ),
            Text('Durée de validité ($validityDuration sécondes)'),
            Slider(
              value: validityDuration.toDouble(),
              min: 10,
              max: 300,
              divisions: 29,
              label: '$validityDuration secondes',
              onChanged: (value) {
                setState(() {
                  validityDuration = value.toInt();
                  updateGenerator();
                });
              },
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Numéro de téléphone'),
              controller: phoneController,
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
            ),
            const SizedBox(height: 40),
            // QR Code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoRegeneratingQRView(
                  data: QRData(
                    payload: {
                      'phoneNumber': phoneNumber,
                    },
                  ),
                  generator: generator,
                  size: 250,
                  style: const QrStyle(
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                  onRegenerate: (result) =>
                      log('Nouveau QR code généré: ${result.toMap()}'),
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $error')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    secretKeyController.dispose();
    super.dispose();
  }
}
