import 'visualizer_step.dart';

enum CnnArchitectureType { linear, residual, inception, dense }

class PredictionResult {
  final String label;
  final double probability;

  const PredictionResult({required this.label, required this.probability});
}

class VisualizerModel {
  final String id;
  final String name;
  final String summary;
  final CnnArchitectureType architectureType;
  final List<VisualizerStep> steps;
  final List<PredictionResult> defaultPredictions;

  const VisualizerModel({
    required this.id,
    required this.name,
    required this.summary,
    required this.architectureType,
    required this.steps,
    required this.defaultPredictions,
  });
}
