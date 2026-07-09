import 'package:cnnvisualizer/features/visualizer/domain/visualizer_model.dart';
import 'package:cnnvisualizer/features/visualizer/domain/visualizer_step.dart';

class CnnModelPresets {
  static const List<VisualizerModel> all = [
    vgg16,
    lenet,
    alexNet,
    resNet50,
    inception,
    denseNet,
    mobileNet,
  ];

  static const vgg16 = VisualizerModel(
    id: 'vgg16',
    name: 'VGG16',
    summary:
        'Linear CNN pipeline that gradually turns pixels into edges, textures, parts, and class scores.',
    architectureType: CnnArchitectureType.linear,
    steps: [
      VisualizerStep(
        id: 'vgg-input',
        title: 'Input',
        subtitle: '224 x 224 x 3',
        type: VisualizerStepType.input,
        description:
            'The model starts from a resized RGB image. At this stage the learner should focus on raw pixels, color, and spatial layout.',
        effectLabel: 'Original image',
        inputShape: '224 x 224 x 3',
        outputShape: '224 x 224 x 3',
        featureLabels: ['color', 'shape', 'layout'],
      ),
      VisualizerStep(
        id: 'vgg-conv1',
        title: 'Conv Block 1',
        subtitle: 'Edges and texture',
        type: VisualizerStepType.convolution,
        description:
            'Early convolution blocks make local patterns more visible, such as edges, simple textures, and color transitions.',
        effectLabel: 'Edges become stronger',
        inputShape: '224 x 224 x 3',
        outputShape: '224 x 224 x 64',
        featureLabels: ['edge', 'texture', 'color'],
      ),
      VisualizerStep(
        id: 'vgg-relu1',
        title: 'ReLU',
        subtitle: 'Keep strong signals',
        type: VisualizerStepType.activation,
        description:
            'Activation keeps positive, useful responses and suppresses weak or negative responses so important regions stand out.',
        effectLabel: 'Weak regions are filtered',
        inputShape: '224 x 224 x 64',
        outputShape: '224 x 224 x 64',
        featureLabels: ['active edge', 'strong texture'],
      ),
      VisualizerStep(
        id: 'vgg-pool1',
        title: 'Pooling',
        subtitle: 'Downsample',
        type: VisualizerStepType.pooling,
        description:
            'Pooling reduces spatial size while keeping the strongest features, making the representation smaller and more stable.',
        effectLabel: 'Image becomes smaller',
        inputShape: '224 x 224 x 64',
        outputShape: '112 x 112 x 64',
        featureLabels: ['dominant edge', 'compact map'],
      ),
      VisualizerStep(
        id: 'vgg-conv2',
        title: 'Conv Block 2',
        subtitle: 'Object parts',
        type: VisualizerStepType.convolution,
        description:
            'Deeper convolution blocks combine simple patterns into higher-level hints such as ears, eyes, fur, wheels, or corners.',
        effectLabel: 'Parts become visible',
        inputShape: '112 x 112 x 64',
        outputShape: '112 x 112 x 128',
        featureLabels: ['ear', 'eye', 'whisker', 'head'],
      ),
      VisualizerStep(
        id: 'vgg-pool2',
        title: 'Pooling',
        subtitle: 'Compact features',
        type: VisualizerStepType.pooling,
        description:
            'A second pooling step compresses the feature maps again so the classifier focuses on the most reliable patterns.',
        effectLabel: 'Key parts remain',
        inputShape: '112 x 112 x 128',
        outputShape: '56 x 56 x 128',
        featureLabels: ['head', 'body', 'outline'],
      ),
      VisualizerStep(
        id: 'vgg-fc',
        title: 'FC',
        subtitle: 'Feature vector',
        type: VisualizerStepType.fullyConnected,
        description:
            'Fully connected layers combine all extracted features into class evidence. This is the bridge from visual features to labels.',
        effectLabel: 'Features become scores',
        inputShape: '7 x 7 x 512',
        outputShape: '4096',
        featureLabels: ['class evidence', 'feature vector'],
      ),
      VisualizerStep(
        id: 'vgg-prediction',
        title: 'Prediction',
        subtitle: 'Class probability',
        type: VisualizerStepType.prediction,
        description:
            'The final step displays educational, simulated probabilities instead of real model inference.',
        effectLabel: 'Probability bars',
        inputShape: '4096',
        outputShape: '1000 classes',
        featureLabels: ['Cat', 'Dog', 'Car'],
      ),
    ],
    defaultPredictions: [
      PredictionResult(label: 'Cat', probability: 0.75),
      PredictionResult(label: 'Dog', probability: 0.20),
      PredictionResult(label: 'Car', probability: 0.05),
    ],
  );

  static const lenet = VisualizerModel(
    id: 'lenet',
    name: 'LeNet',
    summary:
        'Compact classic CNN for explaining the first generation of convolutional classifiers.',
    architectureType: CnnArchitectureType.linear,
    steps: [
      VisualizerStep(
        id: 'lenet-input',
        title: 'Input',
        subtitle: '32 x 32 x 1',
        type: VisualizerStepType.input,
        description:
            'LeNet starts with a small grayscale image, which makes it good for learning basic CNN flow.',
        effectLabel: 'Small grayscale input',
        inputShape: '32 x 32 x 1',
        outputShape: '32 x 32 x 1',
      ),
      VisualizerStep(
        id: 'lenet-conv',
        title: 'Conv',
        subtitle: 'Simple strokes',
        type: VisualizerStepType.convolution,
        description:
            'The first filters respond to strokes, corners, and simple digit-like marks.',
        effectLabel: 'Stroke features',
        inputShape: '32 x 32 x 1',
        outputShape: '28 x 28 x 6',
        featureLabels: ['stroke', 'corner', 'curve'],
      ),
      VisualizerStep(
        id: 'lenet-pool',
        title: 'Pooling',
        subtitle: 'Smaller map',
        type: VisualizerStepType.pooling,
        description:
            'Pooling makes the small feature maps more compact and less sensitive to tiny shifts.',
        effectLabel: 'Compact strokes',
        inputShape: '28 x 28 x 6',
        outputShape: '14 x 14 x 6',
      ),
      VisualizerStep(
        id: 'lenet-prediction',
        title: 'Prediction',
        subtitle: 'Digit class',
        type: VisualizerStepType.prediction,
        description:
            'Class scores are shown as a simplified probability distribution.',
        effectLabel: 'Digit scores',
        inputShape: '120',
        outputShape: '10 classes',
      ),
    ],
    defaultPredictions: [
      PredictionResult(label: '3', probability: 0.68),
      PredictionResult(label: '8', probability: 0.21),
      PredictionResult(label: '5', probability: 0.11),
    ],
  );

  static const alexNet = VisualizerModel(
    id: 'alexnet',
    name: 'AlexNet',
    summary:
        'Classic deeper CNN that demonstrates larger early filters and progressively richer visual features.',
    architectureType: CnnArchitectureType.linear,
    steps: [
      VisualizerStep(
        id: 'alex-input',
        title: 'Input',
        subtitle: '227 x 227 x 3',
        type: VisualizerStepType.input,
        description:
            'AlexNet begins with an RGB image prepared for a deeper visual classification pipeline.',
        effectLabel: 'Original image',
        inputShape: '227 x 227 x 3',
        outputShape: '227 x 227 x 3',
      ),
      VisualizerStep(
        id: 'alex-conv1',
        title: 'Conv 1',
        subtitle: 'Large filters',
        type: VisualizerStepType.convolution,
        description:
            'The early large filters highlight broad edges, contrast, and color blobs.',
        effectLabel: 'Large edge response',
        inputShape: '227 x 227 x 3',
        outputShape: '55 x 55 x 96',
        featureLabels: ['edge', 'color blob', 'contrast'],
      ),
      VisualizerStep(
        id: 'alex-pool',
        title: 'Pooling',
        subtitle: 'Downsample',
        type: VisualizerStepType.pooling,
        description:
            'Pooling reduces feature map size and keeps dominant activations.',
        effectLabel: 'Dominant features',
        inputShape: '55 x 55 x 96',
        outputShape: '27 x 27 x 96',
      ),
      VisualizerStep(
        id: 'alex-deep',
        title: 'Deep Conv',
        subtitle: 'Parts and texture',
        type: VisualizerStepType.convolution,
        description:
            'Deeper AlexNet layers mix basic features into object parts and repeated textures.',
        effectLabel: 'Part heatmap',
        inputShape: '27 x 27 x 96',
        outputShape: '13 x 13 x 256',
        featureLabels: ['part', 'texture', 'shape'],
      ),
      VisualizerStep(
        id: 'alex-prediction',
        title: 'Prediction',
        subtitle: 'Class probability',
        type: VisualizerStepType.prediction,
        description:
            'The final classifier turns features into simulated class probabilities.',
        effectLabel: 'Class scores',
        inputShape: '4096',
        outputShape: '1000 classes',
      ),
    ],
    defaultPredictions: [
      PredictionResult(label: 'Cat', probability: 0.61),
      PredictionResult(label: 'Dog', probability: 0.28),
      PredictionResult(label: 'Bird', probability: 0.11),
    ],
  );

  static const resNet50 = VisualizerModel(
    id: 'resnet50',
    name: 'ResNet50',
    summary:
        'Residual CNN that explains skip connections by comparing residual ON and OFF.',
    architectureType: CnnArchitectureType.residual,
    steps: [
      VisualizerStep(
        id: 'res-input',
        title: 'Input',
        subtitle: '224 x 224 x 3',
        type: VisualizerStepType.input,
        description:
            'ResNet starts from the same kind of RGB image, then uses residual blocks to preserve useful information.',
        effectLabel: 'Original image',
        inputShape: '224 x 224 x 3',
        outputShape: '224 x 224 x 3',
      ),
      VisualizerStep(
        id: 'res-conv',
        title: 'Conv',
        subtitle: 'Base features',
        type: VisualizerStepType.convolution,
        description:
            'Initial convolution extracts base edges and textures before residual blocks refine them.',
        effectLabel: 'Base feature map',
        inputShape: '224 x 224 x 3',
        outputShape: '112 x 112 x 64',
        featureLabels: ['edge', 'texture'],
      ),
      VisualizerStep(
        id: 'res-block',
        title: 'Residual Block',
        subtitle: 'Conv + skip',
        type: VisualizerStepType.residual,
        description:
            'A residual block adds the input shortcut back to the transformed features, helping information flow through deep networks.',
        effectLabel: 'Skip connection added',
        inputShape: '56 x 56 x 256',
        outputShape: '56 x 56 x 256',
        featureLabels: ['main path', 'shortcut', 'sum'],
      ),
      VisualizerStep(
        id: 'res-pool',
        title: 'Pooling',
        subtitle: 'Global evidence',
        type: VisualizerStepType.pooling,
        description:
            'Pooling gathers strong evidence across the feature maps before classification.',
        effectLabel: 'Global summary',
        inputShape: '7 x 7 x 2048',
        outputShape: '2048',
      ),
      VisualizerStep(
        id: 'res-prediction',
        title: 'Prediction',
        subtitle: 'Class probability',
        type: VisualizerStepType.prediction,
        description:
            'The final view shows simplified prediction probabilities.',
        effectLabel: 'Class scores',
        inputShape: '2048',
        outputShape: '1000 classes',
      ),
    ],
    defaultPredictions: [
      PredictionResult(label: 'Cat', probability: 0.70),
      PredictionResult(label: 'Dog', probability: 0.23),
      PredictionResult(label: 'Car', probability: 0.07),
    ],
  );

  static const inception = VisualizerModel(
    id: 'inception',
    name: 'Inception',
    summary:
        'Multi-branch CNN that compares 1x1, 3x3, 5x5, and pooling paths before concatenation.',
    architectureType: CnnArchitectureType.inception,
    steps: [
      VisualizerStep(
        id: 'inc-input',
        title: 'Input',
        subtitle: '299 x 299 x 3',
        type: VisualizerStepType.input,
        description:
            'Inception receives an RGB image and sends the same features into parallel branches.',
        effectLabel: 'Shared input',
        inputShape: '299 x 299 x 3',
        outputShape: '299 x 299 x 3',
        featureLabels: ['color', 'layout', 'object'],
      ),
      VisualizerStep(
        id: 'inc-branch',
        title: 'Branches',
        subtitle: '1x1 / 3x3 / 5x5 / pool',
        type: VisualizerStepType.branch,
        description:
            'Parallel branches look at the same image using different receptive field sizes, so small and large patterns can be captured together.',
        effectLabel: 'Parallel feature scales',
        inputShape: '35 x 35 x 192',
        outputShape: '35 x 35 x mixed',
        featureLabels: ['1x1', '3x3', '5x5', 'pool'],
      ),
      VisualizerStep(
        id: 'inc-concat',
        title: 'Concat',
        subtitle: 'Merge branches',
        type: VisualizerStepType.concat,
        description:
            'Concatenation joins branch outputs into one feature tensor containing multiple feature scales.',
        effectLabel: 'Branches merged',
        inputShape: 'parallel maps',
        outputShape: '35 x 35 x 256',
        featureLabels: ['small edge', 'texture', 'part', 'context'],
      ),
      VisualizerStep(
        id: 'inc-pool',
        title: 'Pooling',
        subtitle: 'Global evidence',
        type: VisualizerStepType.pooling,
        description:
            'Pooling summarizes multi-scale features before classification.',
        effectLabel: 'Scale summary',
        inputShape: '8 x 8 x 2048',
        outputShape: '2048',
      ),
      VisualizerStep(
        id: 'inc-prediction',
        title: 'Prediction',
        subtitle: 'Class probability',
        type: VisualizerStepType.prediction,
        description:
            'The classifier turns the concatenated multi-scale evidence into simulated probabilities.',
        effectLabel: 'Class scores',
        inputShape: '2048',
        outputShape: '1000 classes',
      ),
    ],
    defaultPredictions: [
      PredictionResult(label: 'Cat', probability: 0.66),
      PredictionResult(label: 'Dog', probability: 0.24),
      PredictionResult(label: 'Car', probability: 0.10),
    ],
  );

  static const denseNet = VisualizerModel(
    id: 'densenet',
    name: 'DenseNet',
    summary:
        'Dense CNN that reuses features by connecting each layer to later layers.',
    architectureType: CnnArchitectureType.dense,
    steps: [
      VisualizerStep(
        id: 'dense-input',
        title: 'Input',
        subtitle: '224 x 224 x 3',
        type: VisualizerStepType.input,
        description:
            'DenseNet starts with an RGB image and keeps reusing earlier feature maps through dense connections.',
        effectLabel: 'Original image',
        inputShape: '224 x 224 x 3',
        outputShape: '224 x 224 x 3',
      ),
      VisualizerStep(
        id: 'dense-layer1',
        title: 'Dense Layer 1',
        subtitle: 'Base features',
        type: VisualizerStepType.convolution,
        description:
            'The first dense layer extracts simple patterns that later layers can directly reuse.',
        effectLabel: 'Reusable edges',
        inputShape: '112 x 112 x 64',
        outputShape: '112 x 112 x 96',
        featureLabels: ['edge', 'curve', 'texture'],
      ),
      VisualizerStep(
        id: 'dense-layer2',
        title: 'Dense Layer 2',
        subtitle: 'Feature reuse',
        type: VisualizerStepType.concat,
        description:
            'Dense connections concatenate earlier outputs, so new layers receive both old and new features.',
        effectLabel: 'Features reused',
        inputShape: '112 x 112 x 96',
        outputShape: '112 x 112 x 128',
        featureLabels: ['old edge', 'new texture', 'combined part'],
      ),
      VisualizerStep(
        id: 'dense-transition',
        title: 'Transition',
        subtitle: 'Compress',
        type: VisualizerStepType.pooling,
        description:
            'Transition layers compress the growing set of features to control memory and computation.',
        effectLabel: 'Compressed reuse',
        inputShape: '112 x 112 x 128',
        outputShape: '56 x 56 x 128',
      ),
      VisualizerStep(
        id: 'dense-prediction',
        title: 'Prediction',
        subtitle: 'Class probability',
        type: VisualizerStepType.prediction,
        description:
            'The final classifier uses a rich set of reused features to produce simulated class probabilities.',
        effectLabel: 'Class scores',
        inputShape: '1024',
        outputShape: '1000 classes',
      ),
    ],
    defaultPredictions: [
      PredictionResult(label: 'Cat', probability: 0.72),
      PredictionResult(label: 'Dog', probability: 0.19),
      PredictionResult(label: 'Car', probability: 0.09),
    ],
  );

  static const mobileNet = VisualizerModel(
    id: 'mobilenet',
    name: 'MobileNet',
    summary:
        'Efficient mobile CNN that separates spatial filtering from channel mixing.',
    architectureType: CnnArchitectureType.linear,
    steps: [
      VisualizerStep(
        id: 'mobile-input',
        title: 'Input',
        subtitle: '224 x 224 x 3',
        type: VisualizerStepType.input,
        description:
            'MobileNet prepares a compact image representation for efficient on-device processing.',
        effectLabel: 'Mobile input',
        inputShape: '224 x 224 x 3',
        outputShape: '224 x 224 x 3',
      ),
      VisualizerStep(
        id: 'mobile-depthwise',
        title: 'Depthwise Conv',
        subtitle: 'Spatial filter',
        type: VisualizerStepType.convolution,
        description:
            'Depthwise convolution filters each channel separately, reducing computation while keeping spatial patterns.',
        effectLabel: 'Channel-wise edges',
        inputShape: '112 x 112 x 32',
        outputShape: '112 x 112 x 32',
        featureLabels: ['red edge', 'green edge', 'blue edge'],
      ),
      VisualizerStep(
        id: 'mobile-pointwise',
        title: 'Pointwise Conv',
        subtitle: '1x1 mix',
        type: VisualizerStepType.branch,
        description:
            'Pointwise 1x1 convolution mixes channel information after spatial filtering.',
        effectLabel: 'Channels mixed',
        inputShape: '112 x 112 x 32',
        outputShape: '112 x 112 x 64',
        featureLabels: ['1x1 mix', 'channel blend', 'efficient feature'],
      ),
      VisualizerStep(
        id: 'mobile-pool',
        title: 'Pooling',
        subtitle: 'Compact map',
        type: VisualizerStepType.pooling,
        description:
            'Pooling summarizes efficient feature maps before classification.',
        effectLabel: 'Compact mobile features',
        inputShape: '7 x 7 x 1024',
        outputShape: '1024',
      ),
      VisualizerStep(
        id: 'mobile-prediction',
        title: 'Prediction',
        subtitle: 'Class probability',
        type: VisualizerStepType.prediction,
        description:
            'The final mobile classifier shows simulated prediction probabilities.',
        effectLabel: 'Class scores',
        inputShape: '1024',
        outputShape: '1000 classes',
      ),
    ],
    defaultPredictions: [
      PredictionResult(label: 'Cat', probability: 0.58),
      PredictionResult(label: 'Dog', probability: 0.31),
      PredictionResult(label: 'Car', probability: 0.11),
    ],
  );
}
