import 'package:flutter/material.dart';
import 'package:cnnvisualizer/features/compare/presentation/compare_screen.dart';
import 'package:cnnvisualizer/features/learning/presentation/learn_screen.dart';
import 'package:cnnvisualizer/features/quiz/presentation/quiz_screen.dart';
import 'package:cnnvisualizer/features/visualizer/presentation/visualizer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            const Icon(Icons.visibility, color: Color(0xFF528DFF)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI Vision Lab',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE2E2E8),
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
                    // Hero Section
                    _buildHeroSection(context, isPhone),
                    const SizedBox(height: 24),

                    // Bento Grid Section
                    _buildBentoGrid(context, isPhone),
                    const SizedBox(height: 24),

                    // Recently viewed models
                    _buildRecentlyViewedHeader(context),
                    const SizedBox(height: 12),
                    _buildRecentlyViewedList(context),
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
        child: const Icon(Icons.add_box, color: Color(0xFF0F1115)),
        onPressed: () {},
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 20 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF528DFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'EDUCATION PORTAL',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF528DFF),
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Learn Computer Vision through Interactive Visualization',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isPhone ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE2E2E8),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Dive into the architecture of neural networks. Experiment with real-time model parameters and see the math come to life.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isPhone ? 13 : 14,
              color: const Color(0xFFC2C6D6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: isPhone ? double.infinity : null,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF528DFF),
                foregroundColor: const Color(0xFF0F1115),
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 16 : 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LearnScreen()),
                );
              },
              icon: const Text(
                'START LEARNING',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              label: const Icon(Icons.arrow_forward, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context, bool isPhone) {
    return Column(
      children: [
        // CNN Visualizer - Main visual block
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VisualizerScreen()),
            );
          },
          child: Container(
            constraints: BoxConstraints(
              minHeight: isPhone ? 160 : 180,
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF528DFF).withOpacity(0.15),
                  const Color(0xFF9D59FF).withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF528DFF).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF528DFF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.layers, color: Color(0xFF528DFF), size: 28),
                    ),
                    const Icon(Icons.north_east, color: Color(0xFFC2C6D6), size: 20),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CNN Visualizer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isPhone ? 18 : 20,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Interactive 3D breakdown of Convolutional Neural Networks.',
                      style: TextStyle(color: Color(0xFFC2C6D6), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Bento Cards Grid - Responsive
        LayoutBuilder(
          builder: (context, constraints) {
            if (isPhone || constraints.maxWidth < 700) {
              // Stack vertically on small screens
              return Column(
                children: [
                  _buildBentoCard(
                    context: context,
                    title: 'Model Explorer',
                    subtitle: 'Browse pre-trained vision models.',
                    icon: Icons.grid_view,
                    iconColor: const Color(0xFFD6BAFF),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualizerScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildBentoCard(
                    context: context,
                    title: 'Compare Models',
                    subtitle: 'Benchmark performance metrics.',
                    icon: Icons.compare_arrows,
                    iconColor: const Color(0xFFFFB77D),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompareScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildBentoCard(
                    context: context,
                    title: 'Learning Center',
                    subtitle: 'Theoretical depth and tutorials.',
                    icon: Icons.school,
                    iconColor: const Color(0xFF528DFF),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildBentoCard(
                    context: context,
                    title: 'Knowledge Quiz',
                    subtitle: 'Test your CV understanding.',
                    icon: Icons.quiz,
                    iconColor: const Color(0xFFFBBF24),
                    borderColor: const Color(0xFFFBBF24).withOpacity(0.2),
                    backgroundColor: const Color(0xFFFBBF24).withOpacity(0.05),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen())),
                  ),
                ],
              );
            }

            // Desktop / Tablet - 2 columns
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildBentoCard(
                        context: context,
                        title: 'Model Explorer',
                        subtitle: 'Browse pre-trained vision models.',
                        icon: Icons.grid_view,
                        iconColor: const Color(0xFFD6BAFF),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualizerScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBentoCard(
                        context: context,
                        title: 'Compare Models',
                        subtitle: 'Benchmark performance metrics.',
                        icon: Icons.compare_arrows,
                        iconColor: const Color(0xFFFFB77D),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompareScreen())),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildBentoCard(
                        context: context,
                        title: 'Learning Center',
                        subtitle: 'Theoretical depth and tutorials.',
                        icon: Icons.school,
                        iconColor: const Color(0xFF528DFF),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBentoCard(
                        context: context,
                        title: 'Knowledge Quiz',
                        subtitle: 'Test your CV understanding.',
                        icon: Icons.quiz,
                        iconColor: const Color(0xFFFBBF24),
                        borderColor: const Color(0xFFFBBF24).withOpacity(0.2),
                        backgroundColor: const Color(0xFFFBBF24).withOpacity(0.05),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen())),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF1A1C22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor ?? Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const Icon(Icons.north_east, color: Color(0xFFC2C6D6), size: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFFC2C6D6), fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recently viewed models',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'View All',
            style: TextStyle(
              color: Color(0xFF528DFF),
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewedList(BuildContext context) {
    final models = [
      {'name': 'VGG16', 'params': '138M Params', 'layers': '16 Layers'},
      {'name': 'ResNet50', 'params': '25.6M Params', 'layers': '50 Layers'},
      {'name': 'AlexNet', 'params': '61M Params', 'layers': '8 Layers'},
      {'name': 'LeNet', 'params': '60K Params', 'layers': '5 Layers'},
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: models.length,
        itemBuilder: (context, index) {
          final model = models[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF282A2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.settings_input_component,
                        color: const Color(0xFF528DFF).withOpacity(0.4),
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  model['name']!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFE2E2E8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  model['params']!,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    color: Color(0xFFC2C6D6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}