import 'package:flutter/material.dart';
import 'package:cnnvisualizer/features/quiz/presentation/quiz_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _expandedIndex = 0; // First item expanded by default

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;
    final horizontalPadding = isPhone ? 16.0 : (screenWidth < 900 ? 20.0 : 24.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x991A1C22),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.school, color: Color(0xFF528DFF)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI Vision Lab',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFC2C6D6)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFFC2C6D6)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(isPhone),
                    const SizedBox(height: 24),

                    // Expandable Topics
                    _buildTopicItem(
                      index: 0,
                      icon: Icons.grid_view,
                      iconColor: const Color(0xFF528DFF),
                      title: 'What is Convolution?',
                      subtitle: 'Level 1: Foundations',
                      content: 'Convolution is a mathematical operation on two functions that produces a third function expressing how the shape of one is modified by the other. In CNNs, a kernel slides over the input image to extract features like edges or textures.',
                      formula: '(f * g)(t) = ∫ f(τ) g(t - τ) dτ',
                      btnText: 'PRACTICE CONVOLUTION',
                      isPhone: isPhone,
                    ),
                    const SizedBox(height: 12),
                    _buildTopicItem(
                      index: 1,
                      icon: Icons.compress,
                      iconColor: const Color(0xFFFFB77D),
                      title: 'Spatial Pooling',
                      subtitle: 'Level 2: Dimensionality',
                      content: 'Pooling layers reduce the spatial size of the representation, decreasing the number of parameters and computation in the network. Max Pooling is the most common, selecting the maximum value from the window.',
                      formula: 'y = max(x_{i,j} ∈ R)',
                      btnText: 'TEST DOWNSAMPLING',
                      isPhone: isPhone,
                    ),
                    const SizedBox(height: 12),
                    _buildTopicItem(
                      index: 2,
                      icon: Icons.bolt,
                      iconColor: const Color(0xFFD6BAFF),
                      title: 'Activation Functions',
                      subtitle: 'Level 1: Non-Linearity',
                      content: 'Activation functions introduce non-linear properties to the network. Without them, a neural network would just be a linear regression model. Common types include ReLU, Sigmoid, and Tanh.',
                      formula: 'f(x) = max(0, x) [ReLU]',
                      btnText: 'RUN SIMULATION',
                      isPhone: isPhone,
                    ),
                    const SizedBox(height: 32),

                    // Featured Specialized Lab Sessions
                    Text(
                      'Specialized Lab Sessions',
                      style: TextStyle(
                        fontSize: isPhone ? 17 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecializedLabCard(context, isPhone),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF528DFF),
        child: const Icon(Icons.quiz, color: Color(0xFF0F1115)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizScreen()),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(bool isPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Center',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isPhone ? 26 : 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF528DFF),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Master the architecture of Neural Networks through interactive modules and mathematical rigor.',
          style: TextStyle(
            fontSize: isPhone ? 13 : 14,
            color: const Color(0xFFC2C6D6),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicItem({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String content,
    required String formula,
    required String btnText,
    required bool isPhone,
  }) {
    final isExpanded = _expandedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Header Bar
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: isPhone ? 12 : 16, vertical: 4),
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? -1 : index;
              });
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                color: iconColor,
                letterSpacing: 0.5,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFFC2C6D6),
            ),
          ),
          // Expanded Content Block
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.only(
                left: isPhone ? 12 : 16,
                right: isPhone ? 12 : 16,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFC2C6D6), height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1115),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formula,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: isPhone ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor.withOpacity(0.2),
                        foregroundColor: iconColor,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.science, size: 16),
                      label: FittedBox(
                        child: Text(
                          btnText,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontWeight: FontWeight.bold,
                            fontSize: isPhone ? 11 : 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializedLabCard(BuildContext context, bool isPhone) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = isPhone ? 180.0 : 200.0;

        return Container(
          width: double.infinity,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF528DFF).withOpacity(0.2)),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1507413245164-6160d8298b31?auto=format&fit=crop&q=80&w=600'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isPhone ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Advanced CNN Architectures',
                  style: TextStyle(
                    fontSize: isPhone ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF528DFF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deep dive into ResNet and DenseNet implementations.',
                  style: TextStyle(
                    fontSize: isPhone ? 12 : 12,
                    color: const Color(0xFFC2C6D6),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBadgesRow(isPhone),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesRow(bool isPhone) {
    if (isPhone) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildBadge(Icons.schedule, '45 MINS', const Color(0xFF528DFF)),
          _buildBadge(Icons.star, 'EXPERT', const Color(0xFFFBBF24)),
        ],
      );
    }

    return Row(
      children: [
        _buildBadge(Icons.schedule, '45 MINS', const Color(0xFF528DFF)),
        const SizedBox(width: 8),
        _buildBadge(Icons.star, 'EXPERT', const Color(0xFFFBBF24)),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accentColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
