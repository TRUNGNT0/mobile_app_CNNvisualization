class VisualizerSettings {
  final double kernelSize;
  final double edgeStrength;
  final double poolingSize;
  final double activationThreshold;
  final double noise;
  final double contrast;

  const VisualizerSettings({
    this.kernelSize = 3,
    this.edgeStrength = 60,
    this.poolingSize = 2,
    this.activationThreshold = 35,
    this.noise = 0,
    this.contrast = 50,
  });

  VisualizerSettings copyWith({
    double? kernelSize,
    double? edgeStrength,
    double? poolingSize,
    double? activationThreshold,
    double? noise,
    double? contrast,
  }) {
    return VisualizerSettings(
      kernelSize: kernelSize ?? this.kernelSize,
      edgeStrength: edgeStrength ?? this.edgeStrength,
      poolingSize: poolingSize ?? this.poolingSize,
      activationThreshold: activationThreshold ?? this.activationThreshold,
      noise: noise ?? this.noise,
      contrast: contrast ?? this.contrast,
    );
  }
}
