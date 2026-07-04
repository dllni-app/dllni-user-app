# flutter_cube_transition

[![pub package](https://img.shields.io/pub/v/flutter_cube_transition.svg)](https://pub.dev/packages/flutter_cube_transition)
[![GitHub stars](https://img.shields.io/github/stars/asseries/flutter_cube_transition)](https://github.com/asseries/flutter_cube_transition)
[![GitHub issues](https://img.shields.io/github/issues/asseries/flutter_cube_transition)](https://github.com/asseries/flutter_cube_transition/issues)

A customizable and interactive **3D cube transition** widget for Flutter apps.  
Perfect for building creative UIs, page transitions, or fun interactive elements. ✨

---

## ✨ Features

- 🎛 Interactive drag-based 3D cube rotation
- 🎮 Built-in control buttons (`LEFT`, `RIGHT`, `RESET`)
- 📱 Smooth animations with custom duration & curve
- 💡 Haptic feedback support
- 🎨 Fully customizable cube faces (text, colors, gradients, icons, widgets)
- 🔧 Utility helpers (`CubeUtils`) for quick face creation
- 🖼 Border, padding, margin & radius customization

---

## 📸 Demo

<p  align="center">
<img  src="https://raw.githubusercontent.com/asseries/flutter_cube_transition/main/doc/demo.gif?raw=true"  width="350"/>
<br>
</p>
---

## Simple Code

```dart
FlutterCubeTransition(
            size: MediaQuery.of(context).size.width *.6,
            margin: EdgeInsets.only(top: 140),
            faces: {
              CubeFace.right: CubeFaceData(color: Colors.green),
              CubeFace.left: CubeFaceData(color: Colors.red),
              CubeFace.back: CubeFaceData(color: Colors.white),
              CubeFace.front: CubeFaceData(color: Colors.red),
            },
          ),
```

## Use
```dart
FlutterCubeTransition(
                size: 220,
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
```


## 🚀 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_cube_transition: ^1.0.2
```
