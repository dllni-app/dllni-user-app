import 'package:flutter/material.dart';
import 'package:flutter_cube_transition/flutter_cube_transition.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: InteractiveCubePage());
  }
}

class InteractiveCubePage extends StatefulWidget {
  const InteractiveCubePage({super.key});

  @override
  InteractiveCubePageState createState() => InteractiveCubePageState();
}

class InteractiveCubePageState extends State<InteractiveCubePage> {
  double _currentRotation = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Soataliyev Adxam", style: TextStyle(color: Colors.orange)),
          backgroundColor: Colors.deepOrange,
        ),
        body: Column(
          children: [
            Center(
              child: FlutterCubeTransition(
                width: 220,
                height: 220,
                backgroundColor: Colors.redAccent,
                animationDuration: Duration(milliseconds: 200),
                animationCurve: Curves.easeOut,
                enableHapticFeedback: true,
                perspectiveStrength: 0.002,
                showControls: false,
                margin: EdgeInsets.symmetric(horizontal: 32,vertical: 48),
                textAlign: Alignment.topLeft,
                borderRadius: BorderRadius.circular(16),
                dragSensitivity: 0.008,
                // Biroz sekinroq qilish
                dragThreshold: 0.6,
                // Osonroq switch qilish
                onRotationChanged: (rotation) {
                  setState(() {
                    _currentRotation = rotation;
                  });
                },
                faceTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, offset: Offset(2, 2), blurRadius: 6)],
                ),
                faces: {
                  CubeFace.front: CubeFaceData(
                    color: Colors.red.withOpacity(0.8),
                    text: "OLD",
                    child: Image.network(
                      "https://picsum.photos/512/512?random=5",
                      fit: BoxFit.cover,
                      width: 280,
                      height: 280,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 280,
                          height: 280,
                          color: Colors.red,
                          child: const Icon(Icons.error, color: Colors.white, size: 50),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 280,
                          height: 280,
                          color: Colors.red.withOpacity(0.3),
                          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                        );
                      },
                    ),
                  ),
                  CubeFace.back: CubeFaceData(
                    color: Colors.green.withOpacity(0.8),
                    text: "ORQA",
                    child: Image.network(
                      "https://picsum.photos/512/512?random=3",
                      fit: BoxFit.cover,
                      width: 280,
                      height: 280,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 280,
                          height: 280,
                          color: Colors.green,
                          child: const Icon(Icons.error, color: Colors.white, size: 50),
                        );
                      },
                    ),
                  ),
                  CubeFace.right: CubeFaceData(
                    color: Colors.yellow.withOpacity(0.8),
                    text: "O'NG",
                    child: Image.network("https://picsum.photos/512/512?random=9"),
                  ),
                  CubeFace.left: CubeFaceData(
                    color: Colors.blue.withOpacity(0.8),
                    text: "CHAP",
                    child: Image.network(
                      "https://picsum.photos/512/512?random=7",
                      fit: BoxFit.cover,
                      width: 280,
                      height: 280,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 280,
                          height: 280,
                          color: Colors.blue,
                          child: const Icon(Icons.error, color: Colors.white, size: 50),
                        );
                      },
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
