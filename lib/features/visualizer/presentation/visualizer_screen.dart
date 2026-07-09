import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cnnvisualizer/features/visualizer/application/feature_simulator.dart';
import 'package:cnnvisualizer/features/visualizer/application/opencv_image_processor.dart';
import 'package:cnnvisualizer/features/visualizer/application/visualizer_controller.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_model.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_step.dart';
import 'layer_inspector_screen.dart';

class VisualizerScreen extends StatefulWidget {
  const VisualizerScreen({super.key});

  @override
  State<VisualizerScreen> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends State<VisualizerScreen> {
  late final VisualizerController _controller;
  final OpenCvImageProcessor _openCvProcessor = const OpenCvImageProcessor();
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _playTimer;
  String? _activeOpenCvSignature;
  bool _isHeatmap = true;

  @override
  void initState() {
    super.initState();
    _controller = VisualizerController()..addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!_controller.isPlaying) {
      _playTimer?.cancel();
      _playTimer = null;
    } else {
      _playTimer ??= Timer.periodic(const Duration(milliseconds: 1200), (_) {
        if (!_controller.canGoNext) {
          _controller.stopPlaying();
        } else {
          _controller.nextStep();
        }
      });
    }

    if (mounted) {
      setState(() {});
    }
    _refreshOpenCvPreview();
  }

  Future<void> _refreshOpenCvPreview() async {
    final bytes = _controller.selectedImageBytes;
    if (bytes == null) {
      _activeOpenCvSignature = null;
      return;
    }

    final signature = _openCvSignature(bytes.length);
    if (_activeOpenCvSignature == signature || _controller.isOpenCvProcessing) {
      return;
    }

    _activeOpenCvSignature = signature;
    _controller.setOpenCvProcessing();

    try {
      final result = await _openCvProcessor.process(
        bytes: bytes,
        step: _controller.currentStep,
        settings: _controller.settings,
        residualEnabled: _controller.residualEnabled,
      );

      if (!mounted || _activeOpenCvSignature != signature) {
        return;
      }

      _controller.setOpenCvPreview(
        bytes: result.bytes,
        label: result.label,
        metrics: result.metrics,
      );
    } catch (error) {
      if (!mounted || _activeOpenCvSignature != signature) {
        return;
      }

      _controller.setOpenCvError(error.toString());
    }
  }

  String _openCvSignature(int byteLength) {
    final settings = _controller.settings;
    return [
      byteLength,
      _controller.currentStep.id,
      _controller.selectedImageName ?? '',
      settings.kernelSize.round(),
      settings.edgeStrength.round(),
      settings.poolingSize.round(),
      settings.activationThreshold.round(),
      settings.noise.round(),
      settings.contrast.round(),
      _controller.residualEnabled,
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;
    final horizontalPadding = isPhone ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x991A1C22),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.insights, color: Color(0xFF528DFF)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'CNN Visualizer',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFE2E2E8),
                ),
              ),
            ),
            if (!isPhone) ...[
              const SizedBox(width: 12),
              _buildModelSelector(compact: true),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFC2C6D6)),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPhone) ...[
                    _buildModelSelector(compact: false),
                    const SizedBox(height: 16),
                  ],
                  _buildDashboard(context, isPhone),
                  const SizedBox(height: 24),
                  _buildSectionLabel('ARCHITECTURE PIPELINE'),
                  const SizedBox(height: 12),
                  _buildPipeline(context),
                  const SizedBox(height: 16),
                  _buildStepNavigator(isPhone),
                  const SizedBox(height: 24),
                  _buildControlPanel(context, isPhone),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 12,
        color: Color(0xFFC2C6D6),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildModelSelector({required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 0 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF282A2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _controller.selectedModel.id,
          dropdownColor: const Color(0xFF1A1C22),
          iconEnabledColor: const Color(0xFFC2C6D6),
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF528DFF),
          ),
          items: _controller.models.map((model) {
            return DropdownMenuItem(value: model.id, child: Text(model.name));
          }).toList(),
          onChanged: (modelId) {
            if (modelId != null) {
              _controller.selectModel(modelId);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, bool isPhone) {
    if (isPhone) {
      return Column(
        children: [
          _buildInputCard(context),
          const SizedBox(height: 16),
          _buildOutputCard(context),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: _buildInputCard(context)),
        const SizedBox(width: 16),
        Expanded(flex: 6, child: _buildOutputCard(context)),
      ],
    );
  }

  Widget _buildInputCard(BuildContext context) {
    final imageName =
        _controller.selectedImageName ??
        '${_controller.selectedModel.name} demo input';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'INPUT SOURCE',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    color: Color(0xFFC2C6D6),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildInputAction(
                    Icons.photo_library,
                    () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(width: 6),
                  _buildInputAction(
                    Icons.photo_camera,
                    () => _pickImage(ImageSource.camera),
                  ),
                  if (_controller.hasSelectedImage) ...[
                    const SizedBox(width: 6),
                    _buildInputAction(
                      Icons.restart_alt,
                      _controller.clearSelectedImage,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1115),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_controller.selectedImageBytes != null)
                      Image.memory(
                        _controller.selectedImageBytes!,
                        fit: BoxFit.cover,
                      )
                    else
                      Icon(
                        _inputIconForModel(_controller.selectedModel),
                        color: Colors.white24,
                        size: 56,
                      ),
                    if (_controller.selectedImageBytes != null)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.42),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.black54,
                        child: Text(
                          imageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF282A2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: const Color(0xFF528DFF), size: 16),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    _activeOpenCvSignature = null;
    _controller.setSelectedImage(bytes: bytes, name: image.name);
  }

  IconData _inputIconForModel(VisualizerModel model) {
    if (model.id == 'lenet') {
      return Icons.looks_3;
    }
    return Icons.pets;
  }

  Widget _buildOutputCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 700;
    final step = _controller.currentStep;
    final frame = _controller.currentSimulation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _iconForStep(step.type),
                      color: const Color(0xFF528DFF),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        frame.title.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildViewToggleGroup(isNarrow),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewBody(step, frame),
          const SizedBox(height: 12),
          _buildSimulationMetrics(frame),
          const SizedBox(height: 12),
          _buildActivatedResolution(isNarrow, step),
        ],
      ),
    );
  }

  Widget _buildPreviewBody(VisualizerStep step, FeatureSimulationFrame frame) {
    if (step.type == VisualizerStepType.prediction) {
      return _buildPredictionPreview(frame);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimulationCanvas(step, frame),
        if (_controller.openCvError != null) ...[
          const SizedBox(height: 8),
          _buildOpenCvError(),
        ],
        const SizedBox(height: 12),
        Text(
          frame.caption,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFC2C6D6),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureGrid(step, frame),
      ],
    );
  }

  Widget _buildSimulationCanvas(
    VisualizerStep step,
    FeatureSimulationFrame frame,
  ) {
    if (_controller.openCvPreviewBytes != null) {
      return _buildOpenCvPreview();
    }

    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter: _FeatureSimulationPainter(
              stepType: step.type,
              frame: frame,
              accentColor: _colorForStep(step.type),
              heatmapEnabled: _isHeatmap,
              poolingSize: _controller.settings.poolingSize,
              residualEnabled: _controller.residualEnabled,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.42),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  step.effectLabel,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: Color(0xFFE2E2E8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpenCvPreview() {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                _controller.openCvPreviewBytes!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
              Positioned(top: 10, left: 10, child: _buildOpenCvBadge()),
              if (_controller.isOpenCvProcessing)
                Container(
                  color: Colors.black.withOpacity(0.28),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenCvBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4)),
      ),
      child: Text(
        _controller.openCvPreviewLabel ?? 'OpenCV preview',
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          color: Color(0xFF34D399),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(VisualizerStep step, FeatureSimulationFrame frame) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: frame.gridColumns,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: step.type == VisualizerStepType.fullyConnected
            ? 0.72
            : 1,
      ),
      itemCount: frame.cells.length,
      itemBuilder: (context, index) {
        final cell = frame.cells[index];
        final color = cell.suppressed
            ? Colors.white24
            : _colorForStep(step.type).withOpacity(
                _isHeatmap ? cell.activation : cell.activation * 0.45,
              );

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: cell.suppressed ? Colors.white10 : Colors.white24,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                cell.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: cell.suppressed ? Colors.white38 : Colors.white70,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictionPreview(FeatureSimulationFrame frame) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimulationCanvas(_controller.currentStep, frame),
        if (_controller.openCvError != null) ...[
          const SizedBox(height: 8),
          _buildOpenCvError(),
        ],
        const SizedBox(height: 12),
        Text(
          frame.caption,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFC2C6D6),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        ...frame.predictions.map((prediction) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prediction.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(prediction.probability * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        color: Color(0xFF528DFF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: prediction.probability,
                    minHeight: 8,
                    color: const Color(0xFF528DFF),
                    backgroundColor: Colors.white12,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSimulationMetrics(FeatureSimulationFrame frame) {
    final metrics = {...frame.metrics, ..._controller.openCvMetrics};

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: metrics.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1115),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              color: Color(0xFFC2C6D6),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpenCvError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB4AB).withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB4AB).withOpacity(0.35)),
      ),
      child: Text(
        _controller.openCvError!,
        style: const TextStyle(fontSize: 11, color: Color(0xFFFFB4AB)),
      ),
    );
  }

  Widget _buildViewToggleGroup(bool isNarrow) {
    return Row(
      children: [
        _buildViewToggle('2D', !_isHeatmap),
        const SizedBox(width: 4),
        _buildViewToggle('Heat', _isHeatmap),
      ],
    );
  }

  Widget _buildViewToggle(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isHeatmap = label == 'Heat';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF528DFF).withOpacity(0.2)
              : const Color(0xFF282A2E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF528DFF) : const Color(0xFFC2C6D6),
          ),
        ),
      ),
    );
  }

  Widget _buildActivatedResolution(bool isNarrow, VisualizerStep step) {
    final inputText = 'In: ${step.inputShape}';
    final outputText = 'Out: ${step.outputShape}';

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inputText,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            outputText,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          inputText,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            color: Colors.white54,
          ),
        ),
        Text(
          outputText,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildPipeline(BuildContext context) {
    final steps = _controller.selectedModel.steps;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              _buildPipelineNode(
                context,
                step: steps[index],
                index: index,
                isActive: index == _controller.currentStepIndex,
                isCompleted: index < _controller.currentStepIndex,
              ),
              if (index < steps.length - 1)
                _buildConnectorLine(index < _controller.currentStepIndex),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineNode(
    BuildContext context, {
    required VisualizerStep step,
    required int index,
    required bool isActive,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () {
        _controller.selectStep(index);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LayerInspectorScreen(
              model: _controller.selectedModel,
              initialStepIndex: index,
              settings: _controller.settings,
              residualEnabled: _controller.residualEnabled,
              selectedImageBytes: _controller.selectedImageBytes,
              selectedImageName: _controller.selectedImageName,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF528DFF).withOpacity(0.1)
                    : isCompleted
                    ? const Color(0xFF34D399).withOpacity(0.08)
                    : const Color(0xFF0F1115),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF528DFF)
                      : isCompleted
                      ? const Color(0xFF34D399)
                      : Colors.white10,
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF528DFF).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _iconForStep(step.type),
                color: isActive
                    ? const Color(0xFF528DFF)
                    : isCompleted
                    ? const Color(0xFF34D399)
                    : const Color(0xFFC2C6D6),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? const Color(0xFF528DFF)
                    : const Color(0xFFE2E2E8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              step.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: Color(0xFFC2C6D6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectorLine(bool isGlow) {
    return Container(
      width: 36,
      height: 2,
      color: isGlow ? const Color(0xFF528DFF) : Colors.white12,
    );
  }

  Widget _buildStepNavigator(bool isPhone) {
    final step = _controller.currentStep;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF528DFF).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'STEP ${_controller.currentStepIndex + 1} / ${_controller.stepCount}',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF528DFF),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${step.title}: ${step.effectLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFC2C6D6),
              height: 1.4,
            ),
          ),
          if (_controller.selectedModel.architectureType ==
              CnnArchitectureType.residual) ...[
            const SizedBox(height: 12),
            _buildResidualToggle(),
          ],
          const SizedBox(height: 16),
          if (isPhone)
            Column(
              children: [
                _buildNavigationButton(
                  Icons.arrow_back,
                  'Previous',
                  _controller.canGoPrevious,
                  _controller.previousStep,
                ),
                const SizedBox(height: 8),
                _buildNavigationButton(
                  _controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  _controller.isPlaying ? 'Pause' : 'Play',
                  true,
                  _controller.togglePlaying,
                ),
                const SizedBox(height: 8),
                _buildNavigationButton(
                  Icons.arrow_forward,
                  'Next',
                  _controller.canGoNext,
                  _controller.nextStep,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildNavigationButton(
                    Icons.arrow_back,
                    'Previous',
                    _controller.canGoPrevious,
                    _controller.previousStep,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildNavigationButton(
                    _controller.isPlaying ? Icons.pause : Icons.play_arrow,
                    _controller.isPlaying ? 'Pause' : 'Play',
                    true,
                    _controller.togglePlaying,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildNavigationButton(
                    Icons.arrow_forward,
                    'Next',
                    _controller.canGoNext,
                    _controller.nextStep,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildResidualToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.call_split, color: Color(0xFFFFB77D), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Residual skip connection',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: _controller.residualEnabled,
            activeThumbColor: const Color(0xFF528DFF),
            onChanged: (_) => _controller.toggleResidual(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    IconData icon,
    String label,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? const Color(0xFF528DFF)
              : const Color(0xFF282A2E),
          foregroundColor: enabled
              ? const Color(0xFF0F1115)
              : const Color(0xFFC2C6D6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context, bool isPhone) {
    final settings = _controller.settings;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, color: Color(0xFFD6BAFF)),
                  const SizedBox(width: 8),
                  Text(
                    'Educational Controls',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSlider(
                'Kernel Size',
                settings.kernelSize,
                3,
                7,
                _controller.updateKernelSize,
                'x',
                true,
                divisions: 2,
              ),
              _buildSlider(
                'Edge Strength',
                settings.edgeStrength,
                0,
                100,
                _controller.updateEdgeStrength,
                '%',
                false,
              ),
              _buildSlider(
                'Pooling Size',
                settings.poolingSize,
                2,
                4,
                _controller.updatePoolingSize,
                'x',
                true,
                divisions: 1,
              ),
              _buildSlider(
                'Activation Threshold',
                settings.activationThreshold,
                0,
                100,
                _controller.updateActivationThreshold,
                '%',
                false,
              ),
              _buildSlider(
                'Noise',
                settings.noise,
                0,
                100,
                _controller.updateNoise,
                '%',
                false,
              ),
              _buildSlider(
                'Contrast',
                settings.contrast,
                0,
                100,
                _controller.updateContrast,
                '%',
                false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildLayerIntuitionCard(context),
      ],
    );
  }

  Widget _buildLayerIntuitionCard(BuildContext context) {
    final step = _controller.currentStep;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFFFFB77D)),
              const SizedBox(width: 8),
              Text(
                'Layer Intuition',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB77D).withOpacity(0.1),
              border: const Border(
                left: BorderSide(color: Color(0xFFFFB77D), width: 4),
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              _intuitionForStep(step),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFE2E2E8),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Simulation Rule',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFFC2C6D6),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _simulationRuleForStep(step),
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                color: Color(0xFF528DFF),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _intuitionForStep(VisualizerStep step) {
    return switch (step.type) {
      VisualizerStepType.input =>
        'Input is the raw visual evidence. The model has not learned anything yet; it only receives pixels.',
      VisualizerStepType.convolution =>
        'Convolution is shown as feature emphasis: edges, texture, color transitions, then higher-level object parts.',
      VisualizerStepType.activation =>
        'Activation is shown as a filter that suppresses weak responses and keeps strong regions visible.',
      VisualizerStepType.pooling =>
        'Pooling is shown as compression: the map gets smaller, but dominant patterns remain.',
      VisualizerStepType.fullyConnected =>
        'Fully connected layers are shown as a feature vector that gathers visual evidence for each class.',
      VisualizerStepType.prediction =>
        'Prediction is simulated with probability bars so learners see classification without requiring real inference.',
      VisualizerStepType.residual =>
        _controller.residualEnabled
            ? 'Residual is ON: the shortcut adds the original signal back to the transformed features.'
            : 'Residual is OFF: only the main convolution path remains, so information flow is easier to lose.',
      VisualizerStepType.branch =>
        'Branching shows parallel filters looking for different feature scales at the same time.',
      VisualizerStepType.concat =>
        'Concat merges parallel feature streams into one richer representation.',
    };
  }

  String _simulationRuleForStep(VisualizerStep step) {
    return switch (step.type) {
      VisualizerStepType.input => 'preview = original_image',
      VisualizerStepType.convolution =>
        'preview = enhance_edges(edge_strength, kernel_size)',
      VisualizerStepType.activation =>
        'preview = threshold(feature_map, activation_threshold)',
      VisualizerStepType.pooling =>
        'preview = resize_blocky(feature_map, pooling_size)',
      VisualizerStepType.fullyConnected => 'vector = flatten(feature_maps)',
      VisualizerStepType.prediction =>
        'probability = simulated_softmax(vector)',
      VisualizerStepType.residual =>
        _controller.residualEnabled
            ? 'output = conv_path + shortcut'
            : 'output = conv_path',
      VisualizerStepType.branch => 'branches = [1x1, 3x3, 5x5, pooling]',
      VisualizerStepType.concat => 'output = concat(branches)',
    };
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChange,
    String suffix,
    bool isSquare, {
    int? divisions,
  }) {
    final displayValue = value.round();
    final valueDisplay = isSquare
        ? '$displayValue $suffix $displayValue'
        : '$displayValue$suffix';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Color(0xFFC2C6D6)),
              ),
              Text(
                valueDisplay,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF528DFF),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF528DFF),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF528DFF),
              overlayColor: const Color(0xFF528DFF).withOpacity(0.2),
              trackHeight: 2,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions ?? (max - min).toInt(),
              onChanged: onChange,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForStep(VisualizerStepType type) {
    return switch (type) {
      VisualizerStepType.input => Icons.image,
      VisualizerStepType.convolution => Icons.grid_view,
      VisualizerStepType.activation => Icons.bolt,
      VisualizerStepType.pooling => Icons.view_comfy,
      VisualizerStepType.fullyConnected => Icons.schema,
      VisualizerStepType.prediction => Icons.leaderboard,
      VisualizerStepType.residual => Icons.call_split,
      VisualizerStepType.branch => Icons.account_tree,
      VisualizerStepType.concat => Icons.merge,
    };
  }

  Color _colorForStep(VisualizerStepType type) {
    return switch (type) {
      VisualizerStepType.input => const Color(0xFFC2C6D6),
      VisualizerStepType.convolution => const Color(0xFF528DFF),
      VisualizerStepType.activation => const Color(0xFFFFB77D),
      VisualizerStepType.pooling => const Color(0xFF34D399),
      VisualizerStepType.fullyConnected => const Color(0xFFD6BAFF),
      VisualizerStepType.prediction => const Color(0xFFFBBF24),
      VisualizerStepType.residual => const Color(0xFFFFB77D),
      VisualizerStepType.branch => const Color(0xFF9D59FF),
      VisualizerStepType.concat => const Color(0xFFD6BAFF),
    };
  }
}

class _FeatureSimulationPainter extends CustomPainter {
  final VisualizerStepType stepType;
  final FeatureSimulationFrame frame;
  final Color accentColor;
  final bool heatmapEnabled;
  final double poolingSize;
  final bool residualEnabled;

  const _FeatureSimulationPainter({
    required this.stepType,
    required this.frame,
    required this.accentColor,
    required this.heatmapEnabled,
    required this.poolingSize,
    required this.residualEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0F1115),
          accentColor.withOpacity(heatmapEnabled ? 0.20 : 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    switch (stepType) {
      case VisualizerStepType.input:
        _paintInput(canvas, size);
      case VisualizerStepType.convolution:
        _paintConvolution(canvas, size);
      case VisualizerStepType.activation:
        _paintActivation(canvas, size);
      case VisualizerStepType.pooling:
        _paintPooling(canvas, size);
      case VisualizerStepType.fullyConnected:
        _paintFullyConnected(canvas, size);
      case VisualizerStepType.prediction:
        _paintPrediction(canvas, size);
      case VisualizerStepType.residual:
        _paintResidual(canvas, size);
      case VisualizerStepType.branch:
        _paintConvolution(canvas, size);
      case VisualizerStepType.concat:
        _paintFullyConnected(canvas, size);
    }
  }

  void _paintInput(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final step = size.shortestSide / 7;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    _paintBlob(
      canvas,
      size.center(Offset.zero),
      size.shortestSide * 0.18,
      0.42,
    );
    _paintBlob(
      canvas,
      Offset(size.width * 0.32, size.height * 0.42),
      size.shortestSide * 0.09,
      0.28,
    );
    _paintBlob(
      canvas,
      Offset(size.width * 0.66, size.height * 0.36),
      size.shortestSide * 0.08,
      0.24,
    );
  }

  void _paintConvolution(Canvas canvas, Size size) {
    final count = frame.cells.length;
    for (var i = 0; i < count; i++) {
      final activation = frame.cells[i].activation;
      final y = (i / math.max(1, count - 1)) * size.height;
      final start = Offset(size.width * 0.15, y);
      final end = Offset(
        size.width * (0.68 + activation * 0.22),
        size.height - y,
      );
      final paint = Paint()
        ..color = accentColor.withOpacity(0.18 + activation * 0.55)
        ..strokeWidth = 1 + activation * 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, paint);
    }

    _paintKernelWindow(canvas, size, 0.34);
    _paintKernelWindow(canvas, size, 0.58);
  }

  void _paintActivation(Canvas canvas, Size size) {
    final barWidth = size.width / frame.cells.length;
    for (var i = 0; i < frame.cells.length; i++) {
      final cell = frame.cells[i];
      final height = size.height * cell.activation;
      final rect = Rect.fromLTWH(
        i * barWidth,
        size.height - height,
        barWidth * 0.72,
        height,
      );
      final paint = Paint()
        ..color = cell.suppressed
            ? Colors.white.withOpacity(0.10)
            : accentColor.withOpacity(0.30 + cell.activation * 0.55);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  void _paintPooling(Canvas canvas, Size size) {
    final columns = poolingSize.round() == 4 ? 4 : 6;
    final rows = poolingSize.round() == 4 ? 2 : 3;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final index = (row * columns + col) % frame.cells.length;
        final activation = frame.cells[index].activation;
        final rect = Rect.fromLTWH(
          col * cellWidth + 3,
          row * cellHeight + 3,
          cellWidth - 6,
          cellHeight - 6,
        );
        final paint = Paint()
          ..color = accentColor.withOpacity(0.16 + activation * 0.48);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
      }
    }
  }

  void _paintFullyConnected(Canvas canvas, Size size) {
    final leftX = size.width * 0.18;
    final rightX = size.width * 0.82;
    final nodePaint = Paint()..color = accentColor.withOpacity(0.62);
    final linePaint = Paint()
      ..color = accentColor.withOpacity(0.22)
      ..strokeWidth = 1;

    final leftNodes = List.generate(
      5,
      (index) => Offset(leftX, size.height * (0.18 + index * 0.16)),
    );
    final rightNodes = List.generate(
      4,
      (index) => Offset(rightX, size.height * (0.24 + index * 0.17)),
    );

    for (final left in leftNodes) {
      for (final right in rightNodes) {
        canvas.drawLine(left, right, linePaint);
      }
    }
    for (final node in [...leftNodes, ...rightNodes]) {
      canvas.drawCircle(node, 6, nodePaint);
    }
  }

  void _paintPrediction(Canvas canvas, Size size) {
    final barHeight =
        size.height / math.max(1, frame.predictions.length) * 0.42;
    for (var i = 0; i < frame.predictions.length; i++) {
      final prediction = frame.predictions[i];
      final top = size.height * 0.18 + (i * barHeight * 1.8);
      final rect = Rect.fromLTWH(
        size.width * 0.18,
        top,
        size.width * 0.64 * prediction.probability,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = accentColor.withOpacity(
            0.32 + prediction.probability * 0.55,
          ),
      );
    }
  }

  void _paintResidual(Canvas canvas, Size size) {
    final mainPaint = Paint()
      ..color = accentColor.withOpacity(0.65)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final skipPaint = Paint()
      ..color = (residualEnabled ? const Color(0xFF34D399) : Colors.white24)
          .withOpacity(residualEnabled ? 0.72 : 0.28)
      ..strokeWidth = residualEnabled ? 4 : 2
      ..style = PaintingStyle.stroke;

    final start = Offset(size.width * 0.12, size.height * 0.5);
    final middle = Offset(size.width * 0.48, size.height * 0.5);
    final end = Offset(size.width * 0.88, size.height * 0.5);
    canvas.drawLine(start, middle, mainPaint);
    canvas.drawCircle(middle, 14, mainPaint);
    canvas.drawLine(middle, end, mainPaint);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.14,
        size.width * 0.70,
        size.height * 0.14,
        end.dx,
        end.dy,
      );
    canvas.drawPath(path, skipPaint);
  }

  void _paintKernelWindow(Canvas canvas, Size size, double xFactor) {
    final rect = Rect.fromCenter(
      center: Offset(size.width * xFactor, size.height * 0.5),
      width: size.shortestSide * 0.36,
      height: size.shortestSide * 0.36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _paintBlob(Canvas canvas, Offset center, double radius, double opacity) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = accentColor.withOpacity(opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _FeatureSimulationPainter oldDelegate) {
    return oldDelegate.stepType != stepType ||
        oldDelegate.frame != frame ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.heatmapEnabled != heatmapEnabled ||
        oldDelegate.poolingSize != poolingSize ||
        oldDelegate.residualEnabled != residualEnabled;
  }
}
