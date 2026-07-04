import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


enum SwipDirection { left, right }
/// An interactive 3D cube that responds to horizontal drag gestures
/// Optimized for performance with better memory management and smoother animations
class FlutterCubeTransition extends StatefulWidget {
  final double width;
  final double height;
  final Map<CubeFace, CubeFaceData> faces;
  final bool showControls;
  final double dragSensitivity;
  final double dragThreshold;
  final Duration animationDuration;
  final Curve animationCurve;
  final ValueChanged<double>? onRotationChanged;
  final Color? backgroundColor;
  final TextStyle? faceTextStyle;
  final bool enableHapticFeedback;
  final double perspectiveStrength;
  final Alignment? textAlign;
  final bool? borderVisible;
  final BorderRadius? borderRadius;
  final EdgeInsets? textPadding;
  final EdgeInsets? margin;
  final Duration? secondsToSwipe;
  final SwipDirection swipDirection;

  const FlutterCubeTransition({
    super.key,
    this.width = 280,
    this.height = 280,
    required this.faces,
    this.showControls = true,
    this.dragSensitivity = 0.01,
    this.dragThreshold = 0.5,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeOut,
    this.onRotationChanged,
    this.backgroundColor = Colors.black,
    this.faceTextStyle,
    this.enableHapticFeedback = true,
    this.perspectiveStrength = 0.002,
    this.textAlign = Alignment.bottomCenter,
    this.borderVisible = true,
    this.borderRadius,
    this.textPadding,
    this.margin = const EdgeInsets.all(8.0),
    this.secondsToSwipe,
    this.swipDirection = SwipDirection.right
  });

  @override
  State<FlutterCubeTransition> createState() => _FlutterCubeTransitionState();
}

class _FlutterCubeTransitionState extends State<FlutterCubeTransition>
    with SingleTickerProviderStateMixin {
  // Rotation state variables
  double _currentRotationY = 0;
  double _baseRotationY = 0;
  double _dragOffsetY = 0;

  // Animation controller and related
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isDragging = false;
  Timer? _swipeTimer;

  // Cached values for optimization
  late double _halfSize;
  late double _perspectiveValue;
  late TextStyle _defaultTextStyle;

  // Pre-calculated face rotations for better performance
  static const Map<CubeFace, double> _faceRotations = {
    CubeFace.front: 0,
    CubeFace.right: math.pi / 2,
    CubeFace.back: math.pi,
    CubeFace.left: -math.pi / 2,
  };

  @override
  void initState() {
    super.initState();
    _initializeCache();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(FlutterCubeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.perspectiveStrength != widget.perspectiveStrength) {
      _initializeCache();
    }
  }

  /// Initialize cached values for better performance
  void _initializeCache() {
    _halfSize = widget.width / 2;
    _perspectiveValue = widget.perspectiveStrength;
    _defaultTextStyle = TextStyle(
        color: Colors.white,
        fontSize: widget.width * 0.08,
        fontWeight: FontWeight.bold);
  }

  /// Initialize animation controller and tween
  void _initializeAnimation() {
    if (widget.secondsToSwipe != null) {
      _swipeTimer = Timer.periodic(widget.secondsToSwipe!, (_) {
        if (widget.swipDirection == SwipDirection.right) {
          _rotateRight();
        } else {
          _rotateLeft();
        }
      });
    }
    _animationController =
        AnimationController(duration: widget.animationDuration, vsync: this);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: widget.animationCurve));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _swipeTimer?.cancel();
    super.dispose();
  }

  // Gesture handling methods
  void _onPanStart(DragStartDetails details) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragOffsetY -= details.delta.dx * widget.dragSensitivity;
      _currentRotationY = _baseRotationY + _dragOffsetY;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;

    // Determine snap direction based on drag threshold
    if (_dragOffsetY.abs() > widget.dragThreshold) {
      _baseRotationY += _dragOffsetY > 0 ? math.pi / 2 : -math.pi / 2;

      // Add haptic feedback if enabled
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }

    _animateToPosition();
  }

  /// Animate cube to the target rotation position
  void _animateToPosition() {
    final double startRotationY = _currentRotationY;
    final double endRotationY = _baseRotationY;
    final double rotationDiff = endRotationY - startRotationY;

    void animationListener() {
      final double progress = _rotationAnimation.value;
      final double newRotation = startRotationY + (rotationDiff * progress);

      setState(() {
        _currentRotationY = newRotation;
        _dragOffsetY = _currentRotationY - _baseRotationY;
      });

      widget.onRotationChanged?.call(_currentRotationY);
    }

    _rotationAnimation.addListener(animationListener);

    _animationController.reset();
    _animationController.forward().then((_) {
      _rotationAnimation.removeListener(animationListener);
      setState(() {
        _dragOffsetY = 0;
        _currentRotationY = _baseRotationY;
      });
    });
  }

  // Control button methods
  void _rotateLeft() {
    if (_isDragging || _animationController.isAnimating) return;

    _baseRotationY -= math.pi / 2;
    _animateToPosition();

    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  void _rotateRight() {
    if (_isDragging || _animationController.isAnimating) return;

    _baseRotationY += math.pi / 2;
    _animateToPosition();

    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  void _resetRotation() {
    if (_isDragging || _animationController.isAnimating) return;

    setState(() {
      _baseRotationY = 0;
      _dragOffsetY = 0;
      _currentRotationY = 0;
    });

    widget.onRotationChanged?.call(0);

    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCube(),
          if (widget.showControls)
            SizedBox(
              height: 45,
            ),
          if (widget.showControls) _buildControlButtons(),
        ],
      ),
    );
  }

  /// Build the main cube container with gesture detection
  Widget _buildCube() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(children: _buildOrderedFaces()),
      ),
    );
  }

  /// Build faces in correct z-order for proper depth rendering
  List<Widget> _buildOrderedFaces() {
    // Calculate depths for all faces
    final List<MapEntry<CubeFace, double>> faceDepths = widget.faces.keys
        .map((face) => MapEntry(face, _calculateFaceDepth(face)))
        .toList();

    // Sort faces by depth (back to front rendering)
    faceDepths.sort((a, b) => a.value.compareTo(b.value));

    // Build face widgets in correct order
    return faceDepths
        .map((entry) =>
            _buildCubeFace(face: entry.key, data: widget.faces[entry.key]!))
        .toList();
  }

  /// Calculate the depth (z-coordinate) of a face for proper rendering order
  double _calculateFaceDepth(CubeFace face) {
    final double faceRotation = _faceRotations[face]!;
    final double totalRotation = _currentRotationY + faceRotation;
    return math.cos(totalRotation);
  }

  /// Build control buttons row
  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
            label: 'LEFT', onPressed: _rotateLeft, color: Colors.blue.shade700),
        _buildControlButton(
            label: 'RESET',
            onPressed: _resetRotation,
            color: Colors.grey.shade700),
        _buildControlButton(
            label: 'RIGHT',
            onPressed: _rotateRight,
            color: Colors.yellow.shade700),
      ],
    );
  }

  /// Build individual control button
  Widget _buildControlButton(
      {required String label,
      required VoidCallback onPressed,
      required Color color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: color.withAlpha(76),
      ),
      child: Text(label),
    );
  }

  /// Build individual cube face with optimized transforms and opacity
  Widget _buildCubeFace({required CubeFace face, required CubeFaceData data}) {
    final double faceRotation = _faceRotations[face]!;
    final double totalRotationY = _currentRotationY + faceRotation;
    final double opacity = _calculateFaceOpacity(totalRotationY);

    // Skip rendering faces that are not visible
    if (opacity <= 0.01) return const SizedBox.shrink();

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, _perspectiveValue) // Apply perspective
        ..rotateY(totalRotationY)
        ..translate(0.0, 0.0, -_halfSize), // Move face outward
      child: Opacity(opacity: opacity, child: _buildFaceContainer(data)),
    );
  }

  /// Build face container with styling
  Widget _buildFaceContainer(CubeFaceData data) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: data.color,
        border: widget.borderVisible!
            ? Border.all(
                color: _isDragging ? Colors.white : Colors.white70,
                width: _isDragging ? 2 : 1)
            : null,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(_isDragging ? 204 : 153),
            blurRadius: _isDragging ? 20 : 15,
            spreadRadius: _isDragging ? 5 : 3,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: data.borderRadius ??
            widget.borderRadius ??
            BorderRadius.circular(8),
        child: Stack(
          children: [
            if (data.child != null) data.child!,
            Align(
              alignment: widget.textAlign!,
              child: Padding(
                padding: widget.textPadding ?? const EdgeInsets.all(8.0),
                child: Text(data.text,
                    style: widget.faceTextStyle ?? _defaultTextStyle,
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate face opacity based on viewing angle
  double _calculateFaceOpacity(double totalRotation) {
    final double normalZ = math.cos(totalRotation);

    // Hide back-facing surfaces
    if (normalZ < 0) return 0.0;

    // Apply smooth opacity transition
    return math.min(normalZ * 1.5, 1.0).clamp(0.0, 1.0);
  }
}

/// Enumeration of cube faces
enum CubeFace { front, back, left, right }

/// Data class for cube face configuration
class CubeFaceData {
  final Color color;
  final String text;
  final Widget? child;
  final BorderRadius? borderRadius;
  const CubeFaceData(
      {required this.color, this.text = '', this.child, this.borderRadius});

  /// Create a copy of this face data with modified properties
  CubeFaceData copyWith({Color? color, String? text, Widget? child}) {
    return CubeFaceData(
        color: color ?? this.color,
        text: text ?? this.text,
        child: child ?? this.child);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CubeFaceData &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          text == other.text &&
          child == other.child;

  @override
  int get hashCode => color.hashCode ^ text.hashCode ^ child.hashCode;
}

/// Utility class for creating cube configurations
class CubeUtils {
  /// Create default cube faces with standard colors and labels
  static Map<CubeFace, CubeFaceData> createDefaultFaces() {
    return const {
      CubeFace.front: CubeFaceData(color: Colors.red, text: "FRONT"),
      CubeFace.back: CubeFaceData(color: Colors.green, text: "BACK"),
      CubeFace.right: CubeFaceData(color: Colors.yellow, text: "RIGHT"),
      CubeFace.left: CubeFaceData(color: Colors.blue, text: "LEFT"),
    };
  }

  /// Create gradient cube faces
  static Map<CubeFace, CubeFaceData> createGradientFaces() {
    return {
      CubeFace.front: CubeFaceData(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              "FRONT",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      CubeFace.back: CubeFaceData(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              "BACK",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      CubeFace.right: CubeFaceData(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              "RIGHT",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      CubeFace.left: CubeFaceData(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              "LEFT",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    };
  }

  /// Create icon-based cube faces
  static Map<CubeFace, CubeFaceData> createIconFaces() {
    return const {
      CubeFace.front: CubeFaceData(
        color: Colors.red,
        child: Icon(Icons.home, color: Colors.white, size: 60),
      ),
      CubeFace.back: CubeFaceData(
        color: Colors.green,
        child: Icon(Icons.settings, color: Colors.white, size: 60),
      ),
      CubeFace.right: CubeFaceData(
        color: Colors.yellow,
        child: Icon(Icons.star, color: Colors.white, size: 60),
      ),
      CubeFace.left: CubeFaceData(
        color: Colors.blue,
        child: Icon(Icons.favorite, color: Colors.white, size: 60),
      ),
    };
  }

  /// Normalize rotation angle to 0-2π range
  static double normalizeRotation(double rotation) {
    while (rotation < 0) {
      rotation += 2 * math.pi;
    }
    while (rotation >= 2 * math.pi) {
      rotation -= 2 * math.pi;
    }
    return rotation;
  }

  /// Get the current facing direction based on rotation
  static CubeFace getCurrentFace(double rotationY) {
    final double normalizedRotation = normalizeRotation(rotationY);
    final double quarterPi = math.pi / 4;

    if (normalizedRotation < quarterPi || normalizedRotation >= 7 * quarterPi) {
      return CubeFace.front;
    } else if (normalizedRotation >= quarterPi &&
        normalizedRotation < 3 * quarterPi) {
      return CubeFace.right;
    } else if (normalizedRotation >= 3 * quarterPi &&
        normalizedRotation < 5 * quarterPi) {
      return CubeFace.back;
    } else {
      return CubeFace.left;
    }
  }
}
