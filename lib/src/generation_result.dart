
/// Résultat de la génération d'un QR code sécurisé.
/// Cette classe contient toutes les informations sur le QR code généré,
/// y compris son contenu et ses métadonnées.
class GenerationResult {
  /// Contenu final du QR code (encodé et sécurisé)
  final String qrContent;

  /// Identifiant unique du QR code
  final String id;

  /// Date de génération
  final DateTime generatedAt;

  /// Date d'expiration calculée
  final DateTime expiresAt;

  /// Indique si le contenu est chiffré
  final bool isEncrypted;

  /// Indique si le contenu est signé
  final bool isSigned;

  /// Taille en caractères du contenu final
  final int contentSize;

  const GenerationResult({
    required this.qrContent,
    required this.id,
    required this.generatedAt,
    required this.expiresAt,
    required this.isEncrypted,
    required this.isSigned,
    required this.contentSize,
  });

  /// Indique si le QR code est actuellement valide
  bool get isValid {
    final now = DateTime.now();
    return now.isBefore(expiresAt);
  }

  /// Temps restant avant expiration
  Duration get timeUntilExpiration {
    final now = DateTime.now();
    return expiresAt.difference(now);
  }

  /// Convertit le résultat en Map pour le logging ou le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isEncrypted': isEncrypted,
      'isSigned': isSigned,
      'contentSize': contentSize,
      'isValid': isValid,
      'qrContent': qrContent,
      'timeUntilExpiration': timeUntilExpiration.inSeconds,
    };
  }
}
