import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';
import 'package:secure_qr_generator/src/generation_error.dart';

void main() {
  const testKey = '2024#@#qrcod#orange@##perform#==';

  group('AutoRegeneratingQRView', () {
    late SecureQRGenerator generator;
    late QRData testData;

    setUp(() {
      // Configuration valide avec une clé secrète
      final config = GeneratorConfig(
        secretKey: testKey,
        validityDuration: const Duration(minutes: 5),
        enableEncryption: true,
        enableSignature: true,
      );

      generator = SecureQRGenerator(config);
      testData = const QRData(payload: {'test': 'value'});
    });

    testWidgets('should show loading indicator initially', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AutoRegeneratingQRView(
            data: testData,
            generator: generator,
            builder: (qrData) => const Text('QR Content'), // Évite QrImageView
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('QR Content'), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      // Créer un générateur qui échouera à cause des données invalides
      final mockedGenerator = SecureQRGenerator(GeneratorConfig(
        secretKey: testKey,
      ));

      // Données qui provoqueront une erreur
      final invalidData = QRData(
          payload: List.generate(10000, (i) => i).fold<Map<String, dynamic>>(
              {},
                  (map, i) => map..[i.toString()] = 'very_long_value_that_will_cause_error'
          )
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AutoRegeneratingQRView(
            data: invalidData,
            generator: mockedGenerator,
            builder: (qrData) => const Text('QR Content'),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.textContaining('Erreur:'), findsOneWidget);
    });

    testWidgets('should call callbacks correctly', (tester) async {
      final regenerations = <GenerationResult>[];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AutoRegeneratingQRView(
            data: testData,
            generator: generator,
            regenerationInterval: const Duration(milliseconds: 100),
            onRegenerate: (result) {
              regenerations.add(result);
            },
            builder: (qrData) => Text('QR: $qrData'),
          ),
        ),
      ));

      // Attendre la génération initiale
      await tester.pumpAndSettle();

      // Vérifier qu'au moins une génération a eu lieu
      expect(regenerations, isNotEmpty);
      final firstId = regenerations.first.id;

      // Attendre la régénération
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Vérifier qu'une nouvelle génération a eu lieu avec un ID différent
      expect(
        regenerations.where((r) => r.id != firstId),
        isNotEmpty,
        reason: 'Le QR code devrait avoir été régénéré avec un nouvel ID',
      );
    });

    testWidgets('should apply custom size', (tester) async {
      const customSize = 300.0;
      final key = GlobalKey();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: customSize,
              height: customSize,
              child: AutoRegeneratingQRView(
                key: key,
                data: testData,
                generator: generator,
                size: customSize,
                builder: (qrData) => Container(
                  color: Colors.grey[200], // Pour rendre visible la taille
                  child: const Center(child: Text('QR Content')),
                ),
              ),
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
      expect(box.size.width, equals(customSize));
      expect(box.size.height, equals(customSize));
    });

    testWidgets('should regenerate when data changes', (tester) async {
      int regenerateCount = 0;
      const initialData = QRData(payload: {'test': 'initial'});
      const newData = QRData(payload: {'test': 'updated'});

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AutoRegeneratingQRView(
            data: initialData,
            generator: generator,
            onRegenerate: (_) => regenerateCount++,
            builder: (qrData) => const Text('QR Content'),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(regenerateCount, 1);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AutoRegeneratingQRView(
            data: newData,
            generator: generator,
            onRegenerate: (_) => regenerateCount++,
            builder: (qrData) => const Text('QR Content'),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(regenerateCount, 2);
    });

    testWidgets('should test error callback', (tester) async {
      dynamic capturedError;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AutoRegeneratingQRView(
            data: QRData(
                payload: List.generate(10000, (i) => i).fold<Map<String, dynamic>>(
                    {},
                        (map, i) => map..[i.toString()] = 'very_long_value'
                )
            ),
            generator: generator,
            onError: (error) => capturedError = error,
            builder: (qrData) => const Text('QR Content'),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(capturedError, isNotNull);
      expect(capturedError, isA<GenerationError>());
    });

    testWidgets('should clean up resources on dispose', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AutoRegeneratingQRView(
            data: testData,
            generator: generator,
            regenerationInterval: const Duration(milliseconds: 100),
            builder: (qrData) => const Text('QR Content'),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      // Dispose widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Attendre pour vérifier qu'il n'y a pas d'erreurs
      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}