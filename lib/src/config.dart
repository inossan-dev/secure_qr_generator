/// Configuration pour la génération de QR codes sécurisés.
/// Cette classe regroupe tous les paramètres qui contrôlent la façon dont
/// les QR codes sont générés et sécurisés.
class GeneratorConfig {
  /// Clé secrète utilisée pour le chiffrement et la signature.
  /// Elle doit faire au moins 32 caractères si le chiffrement est activé.
  final String? secretKey;

  /// Durée de validité des QR codes générés.
  /// Après cette durée, les QR codes seront considérés comme expirés.
  final Duration validityDuration;

  /// Active ou désactive le chiffrement du contenu.
  /// Quand activé, le contenu des QR codes n'est lisible que par les
  /// applications possédant la clé secrète.
  final bool enableEncryption;

  /// Active ou désactive la signature numérique.
  /// Quand activé, permet de vérifier l'authenticité des QR codes.
  final bool enableSignature;

  /// Version du format de données utilisé.
  /// Permet une évolution future du format tout en maintenant
  /// la compatibilité avec les anciennes versions.
  final int dataVersion;

  /// Préfixe ajouté aux identifiants uniques.
  /// Permet de distinguer les QR codes de différentes applications
  /// ou environnements.
  final String idPrefix;

  GeneratorConfig({
    this.secretKey,
    this.validityDuration = const Duration(minutes: 5),
    this.enableEncryption = false,
    this.enableSignature = false,
    this.dataVersion = 1,
    this.idPrefix = '',
  }) {
    // Validation des paramètres
    if ((enableEncryption || enableSignature) && secretKey == null) {
      throw ArgumentError(
        'La clé secrète est requise quand le chiffrement ou la signature est activé',
      );
    }

    if (enableEncryption && secretKey != null && secretKey!.length < 32) {
      throw ArgumentError(
        'La clé secrète doit faire au moins 32 caractères quand le chiffrement est activé',
      );
    }

    if (dataVersion < 1) {
      throw ArgumentError('La version doit être supérieure à 0');
    }

    if (validityDuration.inSeconds <= 0) {
      throw ArgumentError('La durée de validité doit être positive');
    }
  }

  /// Crée une configuration pour un environnement de développement
  factory GeneratorConfig.development() {
    return GeneratorConfig(
      secretKey: 'dev_key_for_testing_purposes_only!!!',
      validityDuration: const Duration(hours: 1),
      enableEncryption: true,
      enableSignature: true,
      idPrefix: 'DEV_',
    );
  }

  /// Crée une configuration pour un environnement de production
  /// avec des paramètres de sécurité renforcés
  factory GeneratorConfig.production({
    required String secretKey,
    Duration validityDuration = const Duration(minutes: 5),
  }) {
    if (secretKey.length < 32) {
      throw ArgumentError('La clé de production doit faire au moins 32 caractères');
    }

    return GeneratorConfig(
      secretKey: secretKey,
      validityDuration: validityDuration,
      enableEncryption: true,
      enableSignature: true,
      idPrefix: 'PROD_',
    );
  }
}