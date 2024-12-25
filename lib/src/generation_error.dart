/// Représente une erreur survenue pendant la génération d'un QR code.
class GenerationError extends Error {
  /// Type d'erreur
  final GenerationErrorType type;

  /// Message d'erreur détaillé
  final String message;

  /// Données techniques supplémentaires sur l'erreur
  final Map<String, dynamic>? details;

  GenerationError({
    required this.type,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'GenerationError($type): $message';
}

/// Types d'erreurs possibles lors de la génération
enum GenerationErrorType {
  /// Erreur de configuration (clé manquante, paramètres invalides...)
  configuration,

  /// Erreur lors du chiffrement des données
  encryption,

  /// Erreur lors de la génération de la signature
  signature,

  /// Erreur lors de la sérialisation des données
  serialization,

  /// Taille des données trop importante
  payloadTooLarge,

  /// Erreur inattendue
  unknown,
}