# flutter_fps_viewer

Flutter FPS Viewer.

## Usage

Add dependency in `pubspec.yaml`

```yaml
dependencies:
  flutter_fps_viewer:
    git:
      url: https://github.com/410063005/flutter_fps_viewer.git
      ref: v0.0.1
```

Show fps in an overlay:

```dart 
showFpsViewer(context);
```

Hide fps overlay if necessary:

```dart
hideFpsViewer();
```

You can also use FpsViewerWidget as an Widget:

```dart
Container(
    child: FpsViewerWidget();
)
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).
