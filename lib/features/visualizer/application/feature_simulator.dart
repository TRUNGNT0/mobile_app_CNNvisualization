import 'dart:math' as math;

import 'package:cnnvisualizer/features/visualizer/domain/visualizer_model.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_settings.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_step.dart';

class SimulatedFeatureCell {
  final String label;
  final double activation;
  final bool suppressed;

  const SimulatedFeatureCell({
    required this.label,
    required this.activation,
    this.suppressed = false,
  });
}

class SimulatedPrediction {
  final String label;
  final double probability;

  const SimulatedPrediction({required this.label, required this.probability});
}

class FeatureSimulationFrame {
  final String title;
  final String caption;
  final int gridColumns;
  final List<SimulatedFeatureCell> cells;
  final List<SimulatedPrediction> predictions;
  final Map<String, String> metrics;

  const FeatureSimulationFrame({
    required this.title,
    required this.caption,
    required this.gridColumns,
    required this.cells,
    required this.predictions,
    required this.metrics,
  });
}

class FeatureSimulator {
  const FeatureSimulator();

  FeatureSimulationFrame simulate({
    required VisualizerModel model,
    required VisualizerStep step,
    required VisualizerSettings settings,
    required bool residualEnabled,
  }) {
    final cells = _buildCells(step, settings, residualEnabled);

    return FeatureSimulationFrame(
      title: step.effectLabel,
      caption: _captionFor(step, settings, residualEnabled),
      gridColumns: _columnsFor(step, settings),
      cells: cells,
      predictions: _predictionsFor(model, step, settings, residualEnabled),
      metrics: _metricsFor(step, settings, residualEnabled),
    );
  }

  List<SimulatedFeatureCell> _buildCells(
    VisualizerStep step,
    VisualizerSettings settings,
    bool residualEnabled,
  ) {
    final count = _cellCountFor(step, settings);
    final labels = step.featureLabels.isEmpty
        ? [step.title]
        : step.featureLabels;
    final threshold = settings.activationThreshold / 100;
    final edgeStrength = settings.edgeStrength / 100;
    final noise = settings.noise / 100;
    final contrast = settings.contrast / 100;
    final kernelBoost = (settings.kernelSize - 3) / 8;
    final residualBoost =
        step.type == VisualizerStepType.residual && residualEnabled
        ? 0.18
        : 0.0;

    return List.generate(count, (index) {
      final wave = 0.5 + (math.sin(index * 1.7 + labels.length) * 0.5);
      final deterministicNoise = _noiseAt(index) * noise;
      var activation = 0.18 + (wave * 0.34) + (edgeStrength * 0.28);

      activation += kernelBoost + deterministicNoise + residualBoost;
      activation = ((activation - 0.5) * (0.7 + contrast)) + 0.5;

      if (step.type == VisualizerStepType.input) {
        activation = 0.25 + (wave * 0.25) + deterministicNoise;
      } else if (step.type == VisualizerStepType.activation) {
        activation = activation < threshold
            ? activation * 0.25
            : activation + 0.12;
      } else if (step.type == VisualizerStepType.pooling) {
        activation = activation + 0.10 - ((settings.poolingSize - 2) * 0.08);
      } else if (step.type == VisualizerStepType.fullyConnected) {
        activation = 0.25 + ((index % 4) * 0.14) + edgeStrength * 0.12;
      } else if (step.type == VisualizerStepType.residual && !residualEnabled) {
        activation *= 0.72;
      }

      activation = activation.clamp(0.05, 0.95);
      final suppressed =
          step.type == VisualizerStepType.activation && activation < threshold;

      return SimulatedFeatureCell(
        label: labels[index % labels.length],
        activation: activation,
        suppressed: suppressed,
      );
    });
  }

  List<SimulatedPrediction> _predictionsFor(
    VisualizerModel model,
    VisualizerStep step,
    VisualizerSettings settings,
    bool residualEnabled,
  ) {
    if (step.type != VisualizerStepType.prediction) {
      return const [];
    }

    final quality =
        (settings.edgeStrength * 0.003) +
        (settings.contrast * 0.0015) -
        (settings.noise * 0.002) -
        (settings.activationThreshold * 0.0008) +
        (residualEnabled ? 0.03 : 0.0);

    final adjusted = <double>[];
    for (var i = 0; i < model.defaultPredictions.length; i++) {
      final base = model.defaultPredictions[i].probability;
      if (i == 0) {
        adjusted.add((base + quality).clamp(0.05, 0.92));
      } else {
        adjusted.add((base - quality / (i + 1)).clamp(0.03, 0.72));
      }
    }

    final total = adjusted.fold<double>(0, (sum, value) => sum + value);
    return List.generate(model.defaultPredictions.length, (index) {
      return SimulatedPrediction(
        label: model.defaultPredictions[index].label,
        probability: adjusted[index] / total,
      );
    });
  }

  Map<String, String> _metricsFor(
    VisualizerStep step,
    VisualizerSettings settings,
    bool residualEnabled,
  ) {
    final resolution = switch (step.type) {
      VisualizerStepType.pooling => '${settings.poolingSize.round()}x smaller',
      VisualizerStepType.fullyConnected => 'vectorized',
      VisualizerStepType.prediction => 'softmax-like',
      _ => step.outputShape,
    };

    return {
      'Kernel':
          '${settings.kernelSize.round()} x ${settings.kernelSize.round()}',
      'Edge': '${settings.edgeStrength.round()}%',
      'Threshold': '${settings.activationThreshold.round()}%',
      'Noise': '${settings.noise.round()}%',
      'Resolution': resolution,
      if (step.type == VisualizerStepType.residual)
        'Residual': residualEnabled ? 'ON' : 'OFF',
    };
  }

  String _captionFor(
    VisualizerStep step,
    VisualizerSettings settings,
    bool residualEnabled,
  ) {
    return switch (step.type) {
      VisualizerStepType.input =>
        'Raw demo image. Noise and contrast sliders prepare the educational input view.',
      VisualizerStepType.convolution =>
        'Edges and feature labels become stronger as Edge Strength rises. Larger kernels make broader responses.',
      VisualizerStepType.activation =>
        'Activation Threshold suppresses weak cells and keeps high responses visible.',
      VisualizerStepType.pooling =>
        'Pooling Size controls how aggressively the map is compressed into larger visual blocks.',
      VisualizerStepType.fullyConnected =>
        'Feature maps are flattened into a compact vector of class evidence.',
      VisualizerStepType.prediction =>
        'Probabilities are simulated from feature quality, noise, contrast, and threshold.',
      VisualizerStepType.residual =>
        residualEnabled
            ? 'The shortcut path preserves the earlier signal and boosts the combined output.'
            : 'With the shortcut off, only the transformed path contributes to the output.',
      VisualizerStepType.branch =>
        'Parallel branches show multiple receptive fields operating on the same input.',
      VisualizerStepType.concat =>
        'Concatenation merges branch outputs into one richer representation.',
    };
  }

  int _columnsFor(VisualizerStep step, VisualizerSettings settings) {
    if (step.type == VisualizerStepType.pooling) {
      return settings.poolingSize.round() == 4 ? 3 : 4;
    }
    if (step.type == VisualizerStepType.fullyConnected) {
      return 8;
    }
    if (step.type == VisualizerStepType.input) {
      return 5;
    }
    return 6;
  }

  int _cellCountFor(VisualizerStep step, VisualizerSettings settings) {
    return switch (step.type) {
      VisualizerStepType.input => 15,
      VisualizerStepType.pooling => settings.poolingSize.round() == 4 ? 6 : 8,
      VisualizerStepType.fullyConnected => 24,
      VisualizerStepType.residual => 12,
      _ => 18,
    };
  }

  double _noiseAt(int index) {
    final raw = math.sin((index + 1) * 12.9898) * 43758.5453;
    return (raw - raw.floor()) - 0.5;
  }
}
