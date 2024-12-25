import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:secure_qr_generator/src/generation_error.dart';
import 'package:secure_qr_generator/src/generation_result.dart';
import 'package:secure_qr_generator/src/qr_data.dart';
import 'package:uuid/uuid.dart';

import 'config.dart';

/// Générateur principal pour les QR codes sécurisés.
/// Cette classe implémente toute la logique de génération, incluant :
/// - Chiffrement des données
/// - Signature numérique
/// - Gestion des métadonnées
/// - Horodatage
class SecureQRGenerator {
  /// Configuration du générateur
  final GeneratorConfig config;

  /// Instance de l'encrypteur AES (null si chiffrement désactivé)
  final Encrypter? _encrypter;

  /// Vecteur d'initialisation pour AES
  final IV? _iv;

  /// Générateur d'identifiants uniques
  final Uuid _uuid;

  /// Crée un nouveau générateur avec la configuration spécifiée
  SecureQRGenerator(this.config)
      : _encrypter = config.enableEncryption && config.secretKey != null
      ? Encrypter(AES(Key.fromUtf8(config.secretKey!.padRight(32))))
      : null,
        _iv = config.enableEncryption ? IV.fromLength(16) : null,
        _uuid = const Uuid() {
    // Validation supplémentaire de la configuration
    if (config.enableEncryption && (_encrypter == null || _iv == null)) {
      throw GenerationError(
        type: GenerationErrorType.configuration,
        message: 'Configuration de chiffrement invalide',
      );
    }
  }

  /// Génère un QR code sécurisé à partir des données fournies
  Future<GenerationResult> generateQR(QRData data) async {
    try {
      // Génération de l'identifiant unique
      final id = '${config.idPrefix}${_uuid.v4()}';
      final now = DateTime.now();

      // Construction du payload complet
      final fullPayload = {
        'data': data.toMap(),
        'id': id,
        'timestamp': now.millisecondsSinceEpoch,
        'version': config.dataVersion,
      };

      // Ajout de la signature si activée
      if (config.enableSignature) {
        fullPayload['signature'] = _generateSignature(fullPayload);
      }

      // Sérialisation en JSON
      final jsonPayload = jsonEncode(fullPayload);

      // Vérification de la taille (estimation de la taille finale du QR)
      if (jsonPayload.length > 2000) { // Limite arbitraire pour cet exemple
        throw GenerationError(
          type: GenerationErrorType.payloadTooLarge,
          message: 'Payload trop volumineux',
          details: {'size': jsonPayload.length, 'maxSize': 2000},
        );
      }

      // Chiffrement si activé
      final String finalContent;
      final bool isEncrypted;
      if (config.enableEncryption && _encrypter != null && _iv != null) {
        try {
          final encrypted = _encrypter!.encrypt(jsonPayload, iv: _iv!);
          finalContent = base64Encode(encrypted.bytes);
          isEncrypted = true;
        } catch (e) {
          throw GenerationError(
            type: GenerationErrorType.encryption,
            message: 'Erreur lors du chiffrement',
            details: {'error': e.toString()},
          );
        }
      } else {
        finalContent = base64Encode(utf8.encode(jsonPayload));
        isEncrypted = false;
      }

      // Création du résultat
      return GenerationResult(
        qrContent: finalContent,
        id: id,
        generatedAt: now,
        expiresAt: now.add(config.validityDuration),
        isEncrypted: isEncrypted,
        isSigned: config.enableSignature,
        contentSize: finalContent.length,
      );
    } catch (e) {
      if (e is GenerationError) rethrow;

      throw GenerationError(
        type: GenerationErrorType.unknown,
        message: 'Erreur inattendue: ${e.toString()}',
      );
    }
  }
  /// Génère une signature HMAC-SHA256 pour un payload
  String _generateSignature(Map<String, dynamic> payload) {
    if (!config.enableSignature || config.secretKey == null) {
      throw GenerationError(
        type: GenerationErrorType.signature,
        message: 'Signature désactivée ou clé manquante',
      );
    }

    try {
      final data = jsonEncode(payload);
      final key = utf8.encode(config.secretKey!);
      final bytes = utf8.encode(data);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw GenerationError(
        type: GenerationErrorType.signature,
        message: 'Erreur lors de la génération de la signature',
        details: {'error': e.toString()},
      );
    }
  }

  /// Estime la taille finale du QR code avant la génération
  /// Utile pour vérifier si les données ne sont pas trop volumineuses
  int estimateQRSize(QRData data) {
    try {
      final testPayload = {
        'data': data.toMap(),
        'id': 'test-id',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'version': config.dataVersion,
      };

      final jsonSize = jsonEncode(testPayload).length;

      // Ajout de marge pour la signature si activée
      final signatureSize = config.enableSignature ? 64 : 0;

      // Le chiffrement et l'encodage base64 augmentent la taille d'environ 33%
      final encryptionOverhead = config.enableEncryption ? 0.33 : 0;

      return (jsonSize + signatureSize) * (1 + encryptionOverhead).round();
    } catch (e) {
      throw GenerationError(
        type: GenerationErrorType.unknown,
        message: 'Erreur lors de l\'estimation de la taille',
        details: {'error': e.toString()},
      );
    }
  }

  /// Vérifie si les données peuvent être encodées dans un QR code
  bool canEncodeData(QRData data) {
    try {
      final estimatedSize = estimateQRSize(data);
      return estimatedSize <= 2000; // Limite arbitraire pour cet exemple
    } catch (e) {
      return false;
    }
  }

  /// Crée une version de test du générateur avec une configuration simplifiée
  factory SecureQRGenerator.test() {
    return SecureQRGenerator(GeneratorConfig.development());
  }
}