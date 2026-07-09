enum VisualizerStepType {
  input,
  convolution,
  activation,
  pooling,
  fullyConnected,
  prediction,
  residual,
  branch,
  concat,
}

class VisualizerStep {
  final String id;
  final String title;
  final String subtitle;
  final VisualizerStepType type;
  final String description;
  final String effectLabel;
  final String inputShape;
  final String outputShape;
  final List<String> featureLabels;

  const VisualizerStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.description,
    required this.effectLabel,
    required this.inputShape,
    required this.outputShape,
    this.featureLabels = const [],
  });
}
