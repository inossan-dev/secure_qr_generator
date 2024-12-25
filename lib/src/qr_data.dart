
/// Représente les données à encoder dans un QR code avant sécurisation.
/// Cette classe assure que les données sont dans un format valide
/// avant la génération du QR code.
class QRData {
  /// Données métier à encoder dans le QR code
  final Map<String, dynamic> payload;

  /// Métadonnées optionnelles qui seront incluses dans le QR code
  final Map<String, dynamic>? metadata;

  /// Tags optionnels pour catégoriser ou filtrer les QR codes
  final List<String>? tags;

  const QRData({
    required this.payload,
    this.metadata,
    this.tags,
  });

  /// Convertit les données en Map pour la sérialisation
  Map<String, dynamic> toMap() {
    return {
      'payload': payload,
      if (metadata != null) 'metadata': metadata,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
    };
  }
}
