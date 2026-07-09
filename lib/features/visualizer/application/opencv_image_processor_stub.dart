import 'package:flutter/foundation.dart';

import 'package:cnnvisualizer/features/visualizer/domain/visualizer_settings.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_step.dart';

class OpenCvProcessingResult {
  final Uint8List bytes;
  final String label;
  final Map<String, String> metrics;

  const OpenCvProcessingResult({
    required this.bytes,
    required this.label,
    required this.metrics,
  });
}

class OpenCvImageProcessor {
  const OpenCvImageProcessor();

  Future<OpenCvProcessingResult> process({
    required Uint8List bytes,
    required VisualizerStep step,
    required VisualizerSettings settings,
    required bool residualEnabled,
  }) {
    throw UnsupportedError(
      'OpenCV visualizer requires a native target. Run on Windows, Android, '
      'iOS, macOS, or Linux instead of Web/Chrome.',
    );
  }
}
