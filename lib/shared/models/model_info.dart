

class VisionModel {
  final String name;
  final String params;
  final String description;
  final String imageUrl;

  const VisionModel({
    required this.name,
    required this.params,
    required this.description,
    required this.imageUrl,
  });
}

class PipelineNode {
  final String title;
  final String subtitle;
  final bool isActive;
  final String iconName;

  const PipelineNode({
    required this.title,
    required this.subtitle,
    this.isActive = false,
    required this.iconName,
  });
}

class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String diagramUrl;

  const QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.diagramUrl,
  });
}

class LearningTopic {
  final String title;
  final String subtitle;
  final String content;
  final String formula;
  final String iconName;

  const LearningTopic({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.formula,
    required this.iconName,
  });
}
