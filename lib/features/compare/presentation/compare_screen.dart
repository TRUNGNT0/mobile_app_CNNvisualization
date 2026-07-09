import 'package:flutter/material.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;
    final horizontalPadding = isPhone ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x991A1C22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE2E2E8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Compare Models'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFC2C6D6)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isPhone),
                    const SizedBox(height: 20),

                    // Action Buttons
                    _buildActionButtons(isPhone),
                    const SizedBox(height: 24),

                    // Model Cards
                    _buildModelCard(
                      context,
                      badgeLabel: 'MODEL A',
                      badgeColor: const Color(0xFF528DFF),
                      name: 'EfficientNet-B0',
                      description: 'Compound-scaled CNN architecture designed for mobile efficiency.',
                      blocksCount: 5,
                    ),
                    const SizedBox(height: 16),
                    _buildModelCard(
                      context,
                      badgeLabel: 'MODEL B',
                      badgeColor: const Color(0xFF9D59FF),
                      name: 'ResNet-50',
                      description: 'Residual learning framework to facilitate training of deeper networks.',
                      blocksCount: 7,
                    ),
                    const SizedBox(height: 24),

                    // Structural Density
                    _buildStructuralDensity(context, isPhone),
                    const SizedBox(height: 24),

                    // Top-1 Accuracy
                    _buildTopAccuracy(context, isPhone),
                    const SizedBox(height: 24),

                    // Inference Speed
                    _buildInferenceSpeed(context),
                    const SizedBox(height: 24),

                    // VRAM Utilization
                    _buildVramUtilization(context, isPhone),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compare Models',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isPhone ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE2E2E8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Analyze architectural differences, computational efficiency, and accuracy metrics between neural network vision models.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isPhone ? 13 : 14,
            color: const Color(0xFFC2C6D6),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isPhone) {
    if (isPhone) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF528DFF),
                foregroundColor: const Color(0xFF0F1115),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'New Compare',
                style: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE2E2E8),
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.share, size: 18),
              label: const Text(
                'Export',
                style: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF528DFF),
              foregroundColor: const Color(0xFF0F1115),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'New Compare',
              style: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE2E2E8),
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.share, size: 16),
            label: const Text(
              'Export',
              style: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelCard(
    BuildContext context, {
    required String badgeLabel,
    required Color badgeColor,
    required String name,
    required String description,
    required int blocksCount,
  }) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: badgeColor.withOpacity(0.3)),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
              const Icon(Icons.swap_horiz, color: Color(0xFFC2C6D6)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Color(0xFFC2C6D6)),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1115),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(blocksCount, (index) {
                  final heightFactor = 0.3 + (index % 3) * 0.3;
                  return Container(
                    width: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: badgeColor.withOpacity(0.6)),
                    ),
                    child: FractionallySizedBox(
                      heightFactor: heightFactor,
                      child: Container(),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuralDensity(BuildContext context, bool isPhone) {
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
          const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF528DFF)),
              SizedBox(width: 8),
              Text(
                'Structural Density',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDensityBar(
            'TOTAL PARAMETERS (M)',
            '5.3M',
            '25.6M',
            0.2,
            0.8,
            isPhone,
          ),
          const SizedBox(height: 16),
          _buildDensityBar(
            'NETWORK DEPTH (LAYERS)',
            '237',
            '176',
            0.65,
            0.35,
            isPhone,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF528DFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF528DFF).withOpacity(0.2)),
            ),
            child: const Text(
              'Note: EfficientNet achieves higher accuracy with 5x fewer parameters through compound scaling of resolution, depth, and width.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF528DFF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDensityBar(
    String title,
    String valA,
    String valB,
    double weightA,
    double weightB,
    bool isPhone,
  ) {
    if (isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: Colors.white54)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(valA, style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: Color(0xFF528DFF), fontWeight: FontWeight.bold)),
              Text(valB, style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: Color(0xFF9D59FF), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: (weightA * 100).toInt(), child: Container(color: const Color(0xFF528DFF))),
                  const SizedBox(width: 2),
                  Expanded(flex: (weightB * 100).toInt(), child: Container(color: const Color(0xFF9D59FF))),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: Colors.white54)),
            Row(
              children: [
                Text(valA, style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: Color(0xFF528DFF), fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Text(valB, style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: Color(0xFF9D59FF), fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Expanded(flex: (weightA * 100).toInt(), child: Container(color: const Color(0xFF528DFF))),
                const SizedBox(width: 2),
                Expanded(flex: (weightB * 100).toInt(), child: Container(color: const Color(0xFF9D59FF))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopAccuracy(BuildContext context, bool isPhone) {
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
          const Row(
            children: [
              Icon(Icons.task_alt, color: Color(0xFF34D399)),
              SizedBox(width: 8),
              Text(
                'Top-1 Accuracy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAccuracyCircleRow('EFFICIENTNET-B0', '77.1', const Color(0xFF528DFF), isPhone),
          const Divider(height: 24, color: Colors.white10),
          _buildAccuracyCircleRow('RESNET-50', '76.0', const Color(0xFF9D59FF), isPhone),
        ],
      ),
    );
  }

  Widget _buildAccuracyCircleRow(String label, String score, Color accentColor, bool isPhone) {
    if (isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 4),
                ),
                child: Center(
                  child: Text(
                    score,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const Text('ImageNet benchmark metric', style: TextStyle(fontSize: 11, color: Colors.white54)),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentColor, width: 3),
          ),
          child: Center(
            child: Text(
              score,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('ImageNet benchmark metric', style: TextStyle(fontSize: 11, color: Colors.white54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInferenceSpeed(BuildContext context) {
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
          const Row(
            children: [
              Icon(Icons.speed, color: Color(0xFFFBBF24)),
              SizedBox(width: 8),
              Text(
                'Inference Speed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('MS / IMAGE (CPU)', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Colors.white54)),
          const SizedBox(height: 12),
          _buildSpeedBar('EfficientNet-B0', '4.5ms', 0.45, const Color(0xFF528DFF)),
          const SizedBox(height: 12),
          _buildSpeedBar('ResNet-50', '8.2ms', 0.82, const Color(0xFF9D59FF)),
        ],
      ),
    );
  }

  Widget _buildSpeedBar(String label, String timeDisplay, double widthFactor, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ),
            Text(timeDisplay, style: const TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVramUtilization(BuildContext context, bool isPhone) {
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
          const Row(
            children: [
              Icon(Icons.memory, color: Color(0xFFFFB77D)),
              SizedBox(width: 8),
              Text(
                'VRAM Utilization',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isPhone)
            Column(
              children: [
                _buildVramChartSection(),
                const SizedBox(height: 16),
                _buildEfficiencyCard(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildVramChartSection()),
                const SizedBox(width: 16),
                Expanded(child: _buildEfficiencyCard()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVramChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PEAK ALLOCATION', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: Colors.white54)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildColumnChart('154MB', 0.4, const Color(0xFF528DFF))),
            const SizedBox(width: 12),
            Expanded(child: _buildColumnChart('388MB', 0.9, const Color(0xFF9D59FF))),
          ],
        ),
      ],
    );
  }

  Widget _buildEfficiencyCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Efficiency', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('+60.3%', style: TextStyle(fontSize: 12, color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'Model A is significantly more efficient for edge deployment on low-memory hardware (TPU/Mobile).',
            style: TextStyle(fontSize: 11, color: Colors.white54, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnChart(String label, double heightFactor, Color color) {
    return Column(
      children: [
        Container(
          height: 80 * heightFactor.clamp(0.3, 1.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            border: Border(top: BorderSide(color: color, width: 2)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10)),
      ],
    );
  }
}