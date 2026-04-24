/// Score calculator for terrain listings (0-100)
/// Helps vendors improve their annonce visibility and completeness
class TerrainScoreCalculator {
  /// Calculate reliability score based on terrain data completeness
  /// Returns a score between 0 and 100
  static int calculateScore({
    required String? title,
    required String? description,
    required int photosCount,
    required int documentsCount,
    required String? location,
    required String? quartier,
    required String? ville,
    required double? priceFcfa,
    required double? priceUsd,
    required int? areaSqm,
  }) {
    int score = 0;

    // Title scoring: 0-20 points
    if (title != null && title.isNotEmpty) {
      if (title.length >= 50) {
        score += 20; // Full points for detailed title
      } else if (title.length >= 30) {
        score += 15;
      } else if (title.length >= 15) {
        score += 10;
      } else {
        score += 5;
      }
    }

    // Description scoring: 0-25 points
    if (description != null && description.isNotEmpty) {
      int wordCount = description.split(RegExp(r'\s+')).length;
      if (wordCount >= 100) {
        score += 25; // Excellent description
      } else if (wordCount >= 75) {
        score += 20;
      } else if (wordCount >= 50) {
        score += 15;
      } else if (wordCount >= 25) {
        score += 10;
      } else {
        score += 5;
      }
    }

    // Photos scoring: 0-15 points
    if (photosCount >= 8) {
      score += 15;
    } else if (photosCount >= 5) {
      score += 12;
    } else if (photosCount >= 3) {
      score += 8;
    } else if (photosCount >= 1) {
      score += 4;
    }

    // Documents scoring: 0-10 points
    if (documentsCount >= 5) {
      score += 10;
    } else if (documentsCount >= 3) {
      score += 7;
    } else if (documentsCount >= 1) {
      score += 4;
    }

    // Location scoring: 0-15 points
    int locationPoints = 0;
    if (ville != null && ville.isNotEmpty) locationPoints += 5;
    if (quartier != null && quartier.isNotEmpty) locationPoints += 5;
    if (location != null && location.isNotEmpty) locationPoints += 5;
    score += locationPoints;

    // Price coherence scoring: 0-10 points
    if (priceFcfa != null &&
        priceFcfa > 0 &&
        priceUsd != null &&
        priceUsd > 0) {
      // Check if conversion is approximately correct (1 USD ≈ 655 FCFA)
      double expectedUsdFromFcfa = priceFcfa / 655;
      double deviation =
          ((expectedUsdFromFcfa - priceUsd).abs() / expectedUsdFromFcfa) * 100;

      if (deviation < 5) {
        score += 10; // Prices are well-aligned
      } else if (deviation < 15) {
        score += 7;
      } else if (deviation < 25) {
        score += 4;
      } else {
        score += 1; // Prices seem inconsistent
      }
    } else if ((priceFcfa != null && priceFcfa > 0) ||
        (priceUsd != null && priceUsd > 0)) {
      score += 5; // Partial: has one price
    }

    // Area information: 0-5 bonus points
    if (areaSqm != null && areaSqm > 0) {
      score += 5;
    }

    // Cap score at 100
    return score > 100 ? 100 : score;
  }

  /// Get score level description (FR)
  static String getScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Très bon';
    if (score >= 60) return 'Bon';
    if (score >= 45) return 'Acceptable';
    if (score >= 30) return 'À améliorer';
    return 'Incomplet';
  }

  /// Get score color (for UI display)
  /// Returns hex color based on score
  static String getScoreColor(int score) {
    if (score >= 90) return '#10B981'; // Green - Excellent
    if (score >= 75) return '#3B82F6'; // Blue - Very good
    if (score >= 60) return '#8B5CF6'; // Purple - Good
    if (score >= 45) return '#F59E0B'; // Amber - Acceptable
    if (score >= 30) return '#EF4444'; // Red - Needs work
    return '#999999'; // Gray - Incomplete
  }

  /// Get improvement suggestions based on score weaknesses
  static List<String> getImprovementSuggestions({
    required String? title,
    required String? description,
    required int photosCount,
    required int documentsCount,
    required String? location,
    required String? quartier,
    required String? ville,
    required double? priceFcfa,
    required double? priceUsd,
  }) {
    List<String> suggestions = [];

    if (title == null || title.isEmpty) {
      suggestions.add('Ajoutez un titre descriptif');
    } else if (title.length < 30) {
      suggestions.add('Allongez le titre (recommandé: 50+ caractères)');
    }

    if (description == null || description.isEmpty) {
      suggestions.add('Ajoutez une description détaillée');
    } else {
      int wordCount = description.split(RegExp(r'\s+')).length;
      if (wordCount < 50) {
        suggestions.add('Décrivez plus (recommandé: 100+ mots)');
      }
    }

    if (photosCount == 0) {
      suggestions.add('Ajoutez au moins une photo');
    } else if (photosCount < 5) {
      suggestions.add('Ajoutez plus de photos (recommandé: 5+)');
    }

    if (documentsCount == 0) {
      suggestions.add('Téléchargez des documents (titres, permis, etc.)');
    }

    if (ville == null || ville.isEmpty) {
      suggestions.add('Spécifiez la ville (ex: Tokoin)');
    }

    if (quartier == null || quartier.isEmpty) {
      suggestions.add('Précisez le quartier ou la zone');
    }

    if (priceFcfa == null || priceFcfa <= 0) {
      suggestions.add('Fixez un prix en FCFA');
    }

    if (priceUsd == null || priceUsd <= 0) {
      suggestions.add('Fixez un prix en USD');
    }

    return suggestions;
  }
}
