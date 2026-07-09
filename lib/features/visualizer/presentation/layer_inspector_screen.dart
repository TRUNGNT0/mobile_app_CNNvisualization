import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cnnvisualizer/features/visualizer/application/feature_simulator.dart';
import 'package:cnnvisualizer/features/visualizer/application/opencv_image_processor.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_model.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_settings.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_step.dart';

class LayerInspectorScreen extends StatefulWidget {
  final VisualizerModel model;
  final int initialStepIndex;
  final VisualizerSettings settings;
  final bool residualEnabled;
  final Uint8List? selectedImageBytes;
  final String? selectedImageName;

  const LayerInspectorScreen({
    super.key,
    required this.model,
    required this.initialStepIndex,
    required this.settings,
    required this.residualEnabled,
    this.selectedImageBytes,
    this.selectedImageName,
  });

  @override
  State<LayerInspectorScreen> createState() => _LayerInspectorScreenState();
}

class _LayerInspectorScreenState extends State<LayerInspectorScreen> {
  final FeatureSimulator _simulator = const FeatureSimulator();
  final OpenCvImageProcessor _openCvProcessor = const OpenCvImageProcessor();
  late int _stepIndex;
  double _comparisonValue = 0.52;
  String? _activeOpenCvSignature;
  Uint8List? _openCvPreviewBytes;
  String? _openCvPreviewLabel;
  String? _openCvError;
  bool _isOpenCvProcessing = false;

  VisualizerStep get _step => widget.model.steps[_stepIndex];

  FeatureSimulationFrame get _frame => _simulator.simulate(
    model: widget.model,
    step: _step,
    settings: widget.settings,
    residualEnabled: widget.residualEnabled,
  );

  @override
  void initState() {
    super.initState();
    _stepIndex = widget.initialStepIndex.clamp(
      0,
      widget.model.steps.length - 1,
    );
    unawaited(_refreshOpenCvPreview());
  }

  Future<void> _refreshOpenCvPreview() async {
    final bytes = widget.selectedImageBytes;
    if (bytes == null) {
      if (mounted) {
        setState(() {
          _openCvPreviewBytes = null;
          _openCvPreviewLabel = null;
          _openCvError = null;
          _isOpenCvProcessing = false;
        });
      }
      return;
    }

    final signature = _openCvSignature(bytes.length);
    if (_activeOpenCvSignature == signature || _isOpenCvProcessing) {
      return;
    }

    _activeOpenCvSignature = signature;
    if (mounted) {
      setState(() {
        _isOpenCvProcessing = true;
        _openCvError = null;
      });
    }

    try {
      final result = await _openCvProcessor.process(
        bytes: bytes,
        step: _step,
        settings: widget.settings,
        residualEnabled: widget.residualEnabled,
      );

      if (!mounted || _activeOpenCvSignature != signature) {
        return;
      }

      setState(() {
        _openCvPreviewBytes = result.bytes;
        _openCvPreviewLabel = result.label;
        _openCvError = null;
        _isOpenCvProcessing = false;
      });
    } catch (error) {
      if (!mounted || _activeOpenCvSignature != signature) {
        return;
      }

      setState(() {
        _openCvError = error.toString();
        _isOpenCvProcessing = false;
      });
    }
  }

  String _openCvSignature(int byteLength) {
    final settings = widget.settings;
    return [
      byteLength,
      _step.id,
      widget.selectedImageName ?? '',
      settings.kernelSize.round(),
      settings.edgeStrength.round(),
      settings.poolingSize.round(),
      settings.activationThreshold.round(),
      settings.noise.round(),
      settings.contrast.round(),
      widget.residualEnabled,
    ].join(':');
  }

  void _setStepIndex(int index) {
    if (index == _stepIndex) {
      return;
    }

    setState(() {
      _stepIndex = index;
      _activeOpenCvSignature = null;
    });
    unawaited(_refreshOpenCvPreview());
  }

  @override
  void didUpdateWidget(covariant LayerInspectorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedImageBytes != widget.selectedImageBytes ||
        oldWidget.settings != widget.settings ||
        oldWidget.residualEnabled != widget.residualEnabled ||
        oldWidget.model.id != widget.model.id) {
      _activeOpenCvSignature = null;
      unawaited(_refreshOpenCvPreview());
    }
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x991A1C22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE2E2E8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Layer Inspector',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildInputPreviewSection(),
              const SizedBox(height: 20),
              _buildFlowNodeGraph(),
              const SizedBox(height: 24),
              _buildVisualComparison(frame),
              const SizedBox(height: 24),
              _buildParameters(frame),
              const SizedBox(height: 16),
              _buildExplanation(frame),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF528DFF),
        foregroundColor: const Color(0xFF0F1115),
        onPressed: _stepIndex < widget.model.steps.length - 1
            ? () => _setStepIndex(_stepIndex + 1)
            : null,
        icon: const Text(
          'NEXT LAYER',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        label: const Icon(Icons.arrow_forward_ios, size: 12),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.layers, color: Color(0xFF528DFF), size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${widget.model.name.toUpperCase()} / STEP ${_stepIndex + 1} OF ${widget.model.steps.length}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF528DFF),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _step.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          _step.description,
          style: const TextStyle(
            color: Color(0xFFC2C6D6),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInputPreviewSection() {
    return Container(
      width: double.infinity,
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
              const Icon(Icons.image, color: Color(0xFF528DFF), size: 16),
              const SizedBox(width: 8),
              Text(
                widget.selectedImageName ?? 'Selected input image',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE2E2E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1115),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.selectedImageBytes == null
                    ? const Center(
                        child: Text(
                          'No input image selected',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            widget.selectedImageBytes!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                          Container(color: Colors.black.withOpacity(0.14)),
                          if (_isOpenCvProcessing)
                            Container(
                              color: Colors.black.withOpacity(0.24),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: _buildOpenCvBadge(),
                          ),
                          if (_openCvError != null)
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: _buildOpenCvError(),
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

  Widget _buildFlowNodeGraph() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < widget.model.steps.length; index++) ...[
              _buildMiniNode(widget.model.steps[index], index),
              if (index < widget.model.steps.length - 1) _buildGraphConnector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniNode(VisualizerStep step, int index) {
    final isActive = index == _stepIndex;

    return GestureDetector(
      onTap: () => _setStepIndex(index),
      child: Container(
        constraints: const BoxConstraints(minWidth: 92),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF528DFF) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF528DFF) : Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _iconForStep(step.type),
              color: isActive ? const Color(0xFF0F1115) : Colors.white54,
              size: 18,
            ),
            const SizedBox(height: 6),
            Text(
              step.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF0F1115) : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphConnector() {
    return Container(width: 28, height: 1, color: Colors.white24);
  }

  Widget _buildVisualComparison(FeatureSimulationFrame frame) {
    final hasInputImage = widget.selectedImageBytes != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Visual Comparison',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Input -> Feature Map',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 8,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F1115),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasInputImage && _openCvPreviewBytes != null)
                    Image.memory(
                      _openCvPreviewBytes!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  else
                    _buildFeatureBackground(frame),
                  if (hasInputImage)
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _comparisonValue,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Color(0xFF528DFF),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Image.memory(
                          widget.selectedImageBytes!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  if (!hasInputImage)
                    FractionallySizedBox(
                      alignment: Alignment.centerRight,
                      widthFactor: _comparisonValue,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF528DFF),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Container(
                          color: _colorForStep(_step.type).withOpacity(0.16),
                          child: Center(
                            child: Icon(
                              _iconForStep(_step.type),
                              size: 56,
                              color: _colorForStep(_step.type),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: const Color(0xFF528DFF),
                        overlayColor: const Color(0xFF528DFF).withOpacity(0.1),
                        trackHeight: 0,
                      ),
                      child: Slider(
                        value: 1 - _comparisonValue,
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() => _comparisonValue = 1 - value);
                        },
                      ),
                    ),
                  ),
                  if (_openCvPreviewLabel != null)
                    Positioned(top: 10, left: 10, child: _buildOpenCvBadge()),
                ],
              ),
            ),
          ),
        ),
      ],
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
        _openCvPreviewLabel ?? 'OpenCV preview',
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          color: Color(0xFF34D399),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOpenCvError() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1F1F).withOpacity(0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF7A7A).withOpacity(0.5)),
      ),
      child: Text(
        _openCvError!,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFFFC7C7),
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildFeatureBackground(FeatureSimulationFrame frame) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: frame.gridColumns,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: frame.cells.length,
      itemBuilder: (context, index) {
        final cell = frame.cells[index];
        return Container(
          decoration: BoxDecoration(
            color: _colorForStep(
              _step.type,
            ).withOpacity(cell.suppressed ? 0.08 : cell.activation * 0.35),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      },
    );
  }

  Widget _buildParameters(FeatureSimulationFrame frame) {
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
          const Text(
            'Layer Parameters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF528DFF),
            ),
          ),
          const SizedBox(height: 16),
          _buildShapeRow('Input Shape', _step.inputShape),
          _buildShapeRow('Output Shape', _step.outputShape),
          _buildShapeRow('Effect', _step.effectLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: frame.metrics.entries.map((entry) {
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
          ),
        ],
      ),
    );
  }

  Widget _buildShapeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E2E8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation(FeatureSimulationFrame frame) {
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
          const Text(
            'Analysis Insight',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            frame.caption,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFC2C6D6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Feature Labels',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 11,
              color: Color(0xFF528DFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (_step.featureLabels.isEmpty
                        ? [_step.title]
                        : _step.featureLabels)
                    .map(
                      (label) => Chip(
                        label: Text(label),
                        backgroundColor: const Color(0xFF0F1115),
                        side: const BorderSide(color: Colors.white10),
                        labelStyle: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFE2E2E8),
                        ),
                      ),
                    )
                    .toList(),
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
