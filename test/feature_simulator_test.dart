import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:cnnvisualizer/features/visualizer/application/feature_simulator.dart';
import 'package:cnnvisualizer/features/visualizer/application/visualizer_controller.dart';
import 'package:cnnvisualizer/features/visualizer/data/cnn_model_presets.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_settings.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_step.dart';

void main() {
  const simulator = FeatureSimulator();

  test('edge strength changes convolution activations', () {
    const model = CnnModelPresets.vgg16;
    final step = model.steps.firstWhere(
      (step) => step.type == VisualizerStepType.convolution,
    );

    final weakFrame = simulator.simulate(
      model: model,
      step: step,
      settings: const VisualizerSettings(edgeStrength: 10),
      residualEnabled: true,
    );
    final strongFrame = simulator.simulate(
      model: model,
      step: step,
      settings: const VisualizerSettings(edgeStrength: 95),
      residualEnabled: true,
    );

    final weakAverage = _averageActivation(weakFrame);
    final strongAverage = _averageActivation(strongFrame);

    expect(strongAverage, greaterThan(weakAverage));
  });

  test('prediction probabilities react to noisy settings', () {
    const model = CnnModelPresets.vgg16;
    final step = model.steps.firstWhere(
      (step) => step.type == VisualizerStepType.prediction,
    );

    final cleanFrame = simulator.simulate(
      model: model,
      step: step,
      settings: const VisualizerSettings(
        edgeStrength: 90,
        contrast: 90,
        noise: 0,
      ),
      residualEnabled: true,
    );
    final noisyFrame = simulator.simulate(
      model: model,
      step: step,
      settings: const VisualizerSettings(
        edgeStrength: 10,
        contrast: 20,
        noise: 100,
      ),
      residualEnabled: true,
    );

    expect(
      cleanFrame.predictions.first.probability,
      greaterThan(noisyFrame.predictions.first.probability),
    );
  });

  test('phase 6 presets include branch, dense, and mobile architectures', () {
    final modelIds = CnnModelPresets.all.map((model) => model.id).toSet();

    expect(modelIds, containsAll(['inception', 'densenet', 'mobilenet']));
  });

  test('controller stores and clears selected image bytes', () {
    final controller = VisualizerController();

    controller.setSelectedImage(
      bytes: Uint8List.fromList([1, 2, 3]),
      name: 'sample.png',
    );

    expect(controller.hasSelectedImage, isTrue);
    expect(controller.selectedImageName, 'sample.png');

    controller.clearSelectedImage();

    expect(controller.hasSelectedImage, isFalse);
    expect(controller.selectedImageName, isNull);
  });
}

double _averageActivation(FeatureSimulationFrame frame) {
  final total = frame.cells.fold<double>(
    0,
    (sum, cell) => sum + cell.activation,
  );
  return total / frame.cells.length;
}
