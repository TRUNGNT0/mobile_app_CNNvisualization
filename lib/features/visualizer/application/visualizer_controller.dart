import 'package:flutter/foundation.dart';

import 'package:cnnvisualizer/features/visualizer/data/cnn_model_presets.dart';
import 'package:cnnvisualizer/features/visualizer/application/feature_simulator.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_model.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_settings.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_step.dart';

class VisualizerController extends ChangeNotifier {
  VisualizerController({List<VisualizerModel> models = CnnModelPresets.all})
    : _models = models,
      _selectedModel = models.first;

  final List<VisualizerModel> _models;
  final FeatureSimulator _featureSimulator = const FeatureSimulator();
  VisualizerModel _selectedModel;
  int _currentStepIndex = 0;
  VisualizerSettings _settings = const VisualizerSettings();
  bool _isPlaying = false;
  bool _residualEnabled = true;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  Uint8List? _openCvPreviewBytes;
  String? _openCvPreviewLabel;
  String? _openCvError;
  Map<String, String> _openCvMetrics = const {};
  bool _isOpenCvProcessing = false;

  List<VisualizerModel> get models => List.unmodifiable(_models);
  VisualizerModel get selectedModel => _selectedModel;
  VisualizerStep get currentStep => _selectedModel.steps[_currentStepIndex];
  int get currentStepIndex => _currentStepIndex;
  int get stepCount => _selectedModel.steps.length;
  VisualizerSettings get settings => _settings;
  bool get isPlaying => _isPlaying;
  bool get residualEnabled => _residualEnabled;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get selectedImageName => _selectedImageName;
  bool get hasSelectedImage => _selectedImageBytes != null;
  Uint8List? get openCvPreviewBytes => _openCvPreviewBytes;
  String? get openCvPreviewLabel => _openCvPreviewLabel;
  String? get openCvError => _openCvError;
  Map<String, String> get openCvMetrics => Map.unmodifiable(_openCvMetrics);
  bool get isOpenCvProcessing => _isOpenCvProcessing;
  bool get canGoPrevious => _currentStepIndex > 0;
  bool get canGoNext => _currentStepIndex < stepCount - 1;
  List<PredictionResult> get predictions => _selectedModel.defaultPredictions;
  FeatureSimulationFrame get currentSimulation => _featureSimulator.simulate(
    model: _selectedModel,
    step: currentStep,
    settings: _settings,
    residualEnabled: _residualEnabled,
  );

  void selectModel(String modelId) {
    final nextModel = _models.firstWhere(
      (model) => model.id == modelId,
      orElse: () => _selectedModel,
    );

    if (nextModel.id == _selectedModel.id) {
      return;
    }

    _selectedModel = nextModel;
    _currentStepIndex = 0;
    _isPlaying = false;
    notifyListeners();
  }

  void selectStep(int index) {
    if (index < 0 || index >= stepCount || index == _currentStepIndex) {
      return;
    }

    _currentStepIndex = index;
    notifyListeners();
  }

  void nextStep() {
    if (!canGoNext) {
      _isPlaying = false;
      notifyListeners();
      return;
    }

    _currentStepIndex += 1;
    notifyListeners();
  }

  void previousStep() {
    if (!canGoPrevious) {
      return;
    }

    _currentStepIndex -= 1;
    notifyListeners();
  }

  void togglePlaying() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void stopPlaying() {
    if (!_isPlaying) {
      return;
    }

    _isPlaying = false;
    notifyListeners();
  }

  void toggleResidual() {
    _residualEnabled = !_residualEnabled;
    notifyListeners();
  }

  void setSelectedImage({required Uint8List bytes, required String name}) {
    _selectedImageBytes = bytes;
    _selectedImageName = name;
    _openCvPreviewBytes = null;
    _openCvPreviewLabel = null;
    _openCvError = null;
    _openCvMetrics = const {};
    _currentStepIndex = 0;
    _isPlaying = false;
    notifyListeners();
  }

  void clearSelectedImage() {
    if (_selectedImageBytes == null) {
      return;
    }

    _selectedImageBytes = null;
    _selectedImageName = null;
    _openCvPreviewBytes = null;
    _openCvPreviewLabel = null;
    _openCvError = null;
    _openCvMetrics = const {};
    _isOpenCvProcessing = false;
    _currentStepIndex = 0;
    _isPlaying = false;
    notifyListeners();
  }

  void setOpenCvProcessing() {
    _isOpenCvProcessing = true;
    _openCvError = null;
    notifyListeners();
  }

  void setOpenCvPreview({
    required Uint8List bytes,
    required String label,
    required Map<String, String> metrics,
  }) {
    _openCvPreviewBytes = bytes;
    _openCvPreviewLabel = label;
    _openCvMetrics = metrics;
    _openCvError = null;
    _isOpenCvProcessing = false;
    notifyListeners();
  }

  void setOpenCvError(String message) {
    _openCvError = message;
    _isOpenCvProcessing = false;
    notifyListeners();
  }

  void updateKernelSize(double value) {
    _settings = _settings.copyWith(kernelSize: value);
    notifyListeners();
  }

  void updateEdgeStrength(double value) {
    _settings = _settings.copyWith(edgeStrength: value);
    notifyListeners();
  }

  void updatePoolingSize(double value) {
    _settings = _settings.copyWith(poolingSize: value);
    notifyListeners();
  }

  void updateActivationThreshold(double value) {
    _settings = _settings.copyWith(activationThreshold: value);
    notifyListeners();
  }

  void updateNoise(double value) {
    _settings = _settings.copyWith(noise: value);
    notifyListeners();
  }

  void updateContrast(double value) {
    _settings = _settings.copyWith(contrast: value);
    notifyListeners();
  }
}
