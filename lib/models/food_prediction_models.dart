class FoodPrediction {
  final String label;
  final double confidence;

  FoodPrediction({required this.label, required this.confidence});

  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  Map<String, dynamic> toJson() => {'label': label, 'confidence': confidence};

  factory FoodPrediction.fromJson(Map<String, dynamic> json) => FoodPrediction(
    label: json['label'],
    confidence: json['confidence'].toDouble(),
  );
}
