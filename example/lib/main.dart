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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const QRDisplayScreen(),
    );
  }
}

// Exemple d'utilisation dans un widget Flutter
class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({super.key});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {

  // Configuration du générateur
  final config = GeneratorConfig(
    secretKey: 'votre_clé_secrète_de_production_très_longue',
    validityDuration: const Duration(minutes: 5),
  );

  // Création du générateur
  late SecureQRGenerator generator;

  // Préparation des données
  final qrData = const QRData(
    payload: {
      'phoneNumber': '07070707',
    },
    metadata: {
      'generatedBy': 'Maxit System',
      'environment': 'PROD',
    },
    tags: ['access', 'building_a'],
  );

  generateQR() async {
    try {
      // Vérification préalable de la taille
      if (!generator.canEncodeData(qrData)) {
        print('Données trop volumineuses pour un QR code');
        return;
      }

      // Génération du QR code
      final result = await generator.generateQR(qrData);

      print('QR Code généré avec succès:');
      print('ID: ${result.id}');
      print('Expire le: ${result.expiresAt}');
      print('Taille: ${result.contentSize} caractères');

    } catch (e) {
      print('Erreur lors de la génération: $e');
    }
  }

  @override
  void initState() {
    generator = SecureQRGenerator(config);
    generateQR();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Access')),
      body: Center(
        child: AutoRegeneratingQRView(
          data:  const QRData(
            payload: {
              'phoneNumber': '07070707',
            },
          ),
          generator: generator,
          size: 250,
          style: const QrStyle(
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.blue,
            ),
          ),
          onRegenerate: (result) {
            print('Nouveau QR code généré: ${result.id}');
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: $error')),
            );
          },
        ),
      ),
    );
  }
}

