import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _selectedOption = 1; // Option B selected by default

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
          icon: const Icon(Icons.close, color: Color(0xFFC2C6D6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Vision Lab',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          _buildXPBadge(isPhone),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressHeader(context, isPhone),
                    const SizedBox(height: 10),
                    // Linear Progress Indicator
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: 4 / 12,
                          color: Color(0xFF528DFF),
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Question Text
                    _buildQuestionText(isPhone),
                    const SizedBox(height: 24),

                    // Interactive diagram
                    _buildNetworkDiagram(context),
                    const SizedBox(height: 24),

                    // Options
                    _buildOptionButton(0, 'A', 'Softmax Activation Layer'),
                    const SizedBox(height: 12),
                    _buildOptionButton(1, 'B', 'Max Pooling Layer'),
                    const SizedBox(height: 12),
                    _buildOptionButton(2, 'C', 'Batch Normalization Layer'),
                    const SizedBox(height: 12),
                    _buildOptionButton(3, 'D', 'Dilated Convolutional Filter'),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomSheet: _buildBottomActionPanel(isPhone),
    );
  }

  Widget _buildXPBadge(bool isPhone) {
    return Container(
      margin: EdgeInsets.only(right: isPhone ? 12 : 16, top: 8, bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: isPhone ? 10 : 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF282A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Color(0xFFFBBF24), size: 16),
          if (!isPhone) ...[
            const SizedBox(width: 4),
            const Text(
              '1,240 XP',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E2E8),
              ),
            ),
          ] else
            const SizedBox(width: 4),
          if (isPhone)
            const Text(
              '1240',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E2E8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, bool isPhone) {
    if (isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUESTION 4 OF 12',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC2C6D6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 16),
              const SizedBox(width: 4),
              Text(
                'Score: 300',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF34D399),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'QUESTION 4 OF 12',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFFC2C6D6),
            letterSpacing: 1.0,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 16),
            const SizedBox(width: 4),
            Text(
              'Score: 300',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF34D399),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionText(bool isPhone) {
    return Text(
      'Which layer in a Convolutional Neural Network is primarily responsible for reducing spatial dimensions while retaining critical features?',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: isPhone ? 17 : 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFE2E2E8),
        height: 1.3,
      ),
    );
  }

  Widget _buildNetworkDiagram(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth * 0.45; // Responsive height

        return Container(
          width: double.infinity,
          height: height.clamp(140.0, 220.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: const Color(0xFF528DFF).withOpacity(0.05),
                child: const Center(
                  child: Icon(Icons.schema_outlined, size: 64, color: Colors.white12),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF528DFF).withOpacity(0.3)),
                  ),
                  child: const Text(
                    'LAYER_VISUALIZER_v2.0',
                    style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, color: Color(0xFF528DFF)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(int index, String optionLabel, String text) {
    final isSelected = _selectedOption == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF528DFF).withOpacity(0.05) : const Color(0xFF282A2E).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF528DFF) : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF528DFF) : const Color(0xFF282A2E),
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFF528DFF) : Colors.white24),
              ),
              child: Center(
                child: Text(
                  optionLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF0F1115) : const Color(0xFFC2C6D6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE2E2E8)),
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              const Icon(Icons.radio_button_checked, color: Color(0xFF528DFF))
            else
              const Icon(Icons.radio_button_off, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionPanel(bool isPhone) {
    if (isPhone) {
      return Container(
        color: const Color(0xFF1A1C22),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Skip Question',
                  style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF528DFF),
                  foregroundColor: const Color(0xFF0F1115),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text(
                  'CONFIRM ANSWER',
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF1A1C22),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Skip Question',
              style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF528DFF),
              foregroundColor: const Color(0xFF0F1115),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {},
            label: const Icon(Icons.arrow_forward, size: 16),
            icon: const Text(
              'CONFIRM ANSWER',
              style: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}