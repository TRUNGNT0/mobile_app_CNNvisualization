import 'package:flutter/foundation.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

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
    return compute(
      _processOpenCvImage,
      _OpenCvJob(bytes, step, settings, residualEnabled),
    );
  }
}

class _OpenCvJob {
  final Uint8List bytes;
  final VisualizerStep step;
  final VisualizerSettings settings;
  final bool residualEnabled;

  const _OpenCvJob(this.bytes, this.step, this.settings, this.residualEnabled);
}

OpenCvProcessingResult _processOpenCvImage(_OpenCvJob job) {
  final src = cv.imdecode(job.bytes, cv.IMREAD_COLOR);
  if (src.rows == 0 || src.cols == 0) {
    throw StateError('OpenCV could not decode the selected image.');
  }

  final base = cv.resize(src, (512, 512), interpolation: cv.INTER_AREA);
  final processed = _processByStep(
    base,
    job.step,
    job.settings,
    job.residualEnabled,
  );
  final (success, encoded) = cv.imencode('.jpg', processed);

  if (!success) {
    throw StateError('OpenCV could not encode the processed image.');
  }

  return OpenCvProcessingResult(
    bytes: encoded,
    label: _labelFor(job.step),
    metrics: {
      'OpenCV': 'ON',
      'Rows': '${processed.rows}',
      'Cols': '${processed.cols}',
      'Channels': '${processed.channels}',
      'Operation': _operationFor(job.step, job.residualEnabled),
    },
  );
}

cv.Mat _processByStep(
  cv.Mat base,
  VisualizerStep step,
  VisualizerSettings settings,
  bool residualEnabled,
) {
  return switch (step.type) {
    VisualizerStepType.input => _applyInput(base, settings),
    VisualizerStepType.convolution => _applyConvolution(base, settings),
    VisualizerStepType.activation => _applyActivation(base, settings),
    VisualizerStepType.pooling => _applyPooling(base, settings),
    VisualizerStepType.fullyConnected => _applyFeatureVector(base, settings),
    VisualizerStepType.prediction => _applyPredictionHeatmap(base, settings),
    VisualizerStepType.residual => _applyResidual(
      base,
      settings,
      residualEnabled,
    ),
    VisualizerStepType.branch => _applyBranch(base, settings),
    VisualizerStepType.concat => _applyConcat(base, settings),
  };
}

cv.Mat _applyInput(cv.Mat base, VisualizerSettings settings) {
  final alpha = 0.7 + settings.contrast / 80;
  final beta = settings.noise / 2;
  return cv.convertScaleAbs(base, alpha: alpha, beta: beta);
}

cv.Mat _applyConvolution(cv.Mat base, VisualizerSettings settings) {
  final gray = cv.cvtColor(base, cv.COLOR_BGR2GRAY);
  final kernel = _oddKernel(settings.kernelSize.round());
  final blurred = cv.gaussianBlur(gray, (kernel, kernel), 0);
  final low = 20 + settings.edgeStrength;
  final high = 80 + settings.edgeStrength * 1.8;
  final edges = cv.canny(blurred, low, high, apertureSize: 3);
  return cv.applyColorMap(edges, cv.COLORMAP_TURBO);
}

cv.Mat _applyActivation(cv.Mat base, VisualizerSettings settings) {
  final gray = cv.cvtColor(base, cv.COLOR_BGR2GRAY);
  final thresholdValue = settings.activationThreshold * 2.55;
  final (_, thresholded) = cv.threshold(
    gray,
    thresholdValue,
    255,
    cv.THRESH_BINARY,
  );
  return cv.applyColorMap(thresholded, cv.COLORMAP_INFERNO);
}

cv.Mat _applyPooling(cv.Mat base, VisualizerSettings settings) {
  final factor = settings.poolingSize.round().clamp(2, 4);
  final smallSize = (512 ~/ (factor * 4), 512 ~/ (factor * 4));
  final small = cv.resize(base, smallSize, interpolation: cv.INTER_AREA);
  return cv.resize(small, (512, 512), interpolation: cv.INTER_NEAREST);
}

cv.Mat _applyFeatureVector(cv.Mat base, VisualizerSettings settings) {
  final gray = cv.cvtColor(base, cv.COLOR_BGR2GRAY);
  final vectorMap = cv.resize(gray, (64, 8), interpolation: cv.INTER_AREA);
  final expanded = cv.resize(vectorMap, (
    512,
    128,
  ), interpolation: cv.INTER_NEAREST);
  return cv.applyColorMap(expanded, cv.COLORMAP_VIRIDIS);
}

cv.Mat _applyPredictionHeatmap(cv.Mat base, VisualizerSettings settings) {
  final gray = cv.cvtColor(base, cv.COLOR_BGR2GRAY);
  final pooled = cv.resize(gray, (24, 24), interpolation: cv.INTER_AREA);
  final expanded = cv.resize(pooled, (512, 512), interpolation: cv.INTER_CUBIC);
  return cv.applyColorMap(expanded, cv.COLORMAP_JET);
}

cv.Mat _applyResidual(
  cv.Mat base,
  VisualizerSettings settings,
  bool residualEnabled,
) {
  if (!residualEnabled) {
    return _applyConvolution(base, settings);
  }

  final conv = _applyConvolution(base, settings);
  final baseLite = cv.convertScaleAbs(base, alpha: 0.7, beta: 0);
  return cv.addWeighted(conv, 0.62, baseLite, 0.38, 0);
}

cv.Mat _applyBranch(cv.Mat base, VisualizerSettings settings) {
  final gray = cv.cvtColor(base, cv.COLOR_BGR2GRAY);
  final edge = cv.canny(gray, 40, 140);
  final pooled = cv.resize(
    cv.resize(gray, (64, 64), interpolation: cv.INTER_AREA),
    (512, 512),
    interpolation: cv.INTER_NEAREST,
  );
  final heat = cv.applyColorMap(edge, cv.COLORMAP_TURBO);
  final poolHeat = cv.applyColorMap(pooled, cv.COLORMAP_OCEAN);
  return cv.addWeighted(heat, 0.58, poolHeat, 0.42, 0);
}

cv.Mat _applyConcat(cv.Mat base, VisualizerSettings settings) {
  final branch = _applyBranch(base, settings);
  final vector = _applyFeatureVector(base, settings);
  final vectorWide = cv.resize(vector, (
    512,
    512,
  ), interpolation: cv.INTER_NEAREST);
  return cv.addWeighted(branch, 0.64, vectorWide, 0.36, 0);
}

int _oddKernel(int value) {
  final clamped = value.clamp(3, 7);
  return clamped.isOdd ? clamped : clamped + 1;
}

String _labelFor(VisualizerStep step) {
  return switch (step.type) {
    VisualizerStepType.input => 'OpenCV resized input',
    VisualizerStepType.convolution => 'OpenCV Canny edge map',
    VisualizerStepType.activation => 'OpenCV threshold activation',
    VisualizerStepType.pooling => 'OpenCV block pooling',
    VisualizerStepType.fullyConnected => 'OpenCV feature vector map',
    VisualizerStepType.prediction => 'OpenCV heatmap summary',
    VisualizerStepType.residual => 'OpenCV residual blend',
    VisualizerStepType.branch => 'OpenCV parallel branch mix',
    VisualizerStepType.concat => 'OpenCV concatenated feature map',
  };
}

String _operationFor(VisualizerStep step, bool residualEnabled) {
  return switch (step.type) {
    VisualizerStepType.input => 'resize + contrast',
    VisualizerStepType.convolution => 'grayscale + blur + canny',
    VisualizerStepType.activation => 'grayscale + threshold',
    VisualizerStepType.pooling => 'area resize + nearest resize',
    VisualizerStepType.fullyConnected => 'grayscale + compact resize',
    VisualizerStepType.prediction => 'pooled heatmap',
    VisualizerStepType.residual =>
      residualEnabled ? 'canny + weighted shortcut' : 'canny only',
    VisualizerStepType.branch => 'canny + pooled heatmap',
    VisualizerStepType.concat => 'branch + vector blend',
  };
}
