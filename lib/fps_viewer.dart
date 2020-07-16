import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';

/// https://gist.github.com/yrom/ac4f30b26ee02ce3bd3a1d260bb9ffb4

const maxframes = 60;

const frameInterval =
    const Duration(microseconds: Duration.microsecondsPerSecond ~/ 60);

class FpsViewerWidget extends StatefulWidget {
  final Color textColor;

  const FpsViewerWidget({Key key, this.textColor = Colors.red})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FpsViewerWidgetState();
}

class _FpsViewerWidgetState extends State<FpsViewerWidget> {
  StreamController<num> _controller;

  TextStyle _textStyle;

  final lastFrames = ListQueue<FrameTiming>(maxframes);

  @override
  void initState() {
    super.initState();
    _textStyle = TextStyle(color: widget.textColor);
    _controller = StreamController<num>();
    WidgetsBinding.instance.addTimingsCallback(onReportTimings);
  }

  @override
  void dispose() {
    super.dispose();
    lastFrames.clear();
    WidgetsBinding.instance.removeTimingsCallback(onReportTimings);
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _controller.stream,
        builder: (BuildContext context, AsyncSnapshot<num> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('加载中...');
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Text('已结束.');
          } else if (snapshot.connectionState == ConnectionState.active) {
            return Text(
              'fps: ${snapshot.data.toStringAsFixed(1)}',
              style: _textStyle,
            );
          } else {
            return Text('已结束');
          }
        });
  }

  void onReportTimings(List<FrameTiming> timings) {
    for (FrameTiming timing in timings) {
      lastFrames.addFirst(timing);
    }

    while (lastFrames.length >= maxframes) {
      lastFrames.removeLast();
    }

    if (_controller != null) {
      _controller.add(fps);
    }
  }

  double get fps {
    //var lastFramesSet = <FrameTiming>[...lastFrames];
    var lastFramesSet = <FrameTiming>[];
    lastFramesSet.addAll(lastFrames);

    // for (FrameTiming timing in lastFrames) {
    //   if (lastFramesSet.isEmpty) {
    //     lastFramesSet.add(timing);
    //   } else {
    //     var lastStart =
    //         lastFramesSet.last.timestampInMicroseconds(FramePhase.buildStart);
    //     if (lastStart -
    //             timing.timestampInMicroseconds(FramePhase.rasterFinish) >
    //         (frameInterval.inMicroseconds * 2)) {
    //       // in different set
    //       break;
    //     }
    //     lastFramesSet.add(timing);
    //   }
    // }
    var frameCount = lastFramesSet.length;
    var costCount = lastFramesSet.map((t) {
      return (t.totalSpan.inMicroseconds ~/ frameInterval.inMicroseconds) + 1;
    }).fold(0, (a, b) => a + b);
    return frameCount * 60 / costCount;
  }
}

OverlayEntry _fpsViewerEntry;

showFpsViewer(BuildContext context, {int bottom = 0, Color textColor = Colors.red}) {
  if (_fpsViewerEntry == null) {
    _fpsViewerEntry = OverlayEntry(
        builder: (BuildContext context) => Positioned(
            bottom: 0,
            right: 0,
            child: SafeArea(
              child: Material(
                child: FpsViewerWidget(
                  textColor: textColor,
                ),
              ),
            )));
  }
  Overlay.of(context).insert(_fpsViewerEntry);
}

hideFpsViewer() {
  _fpsViewerEntry?.remove();
  _fpsViewerEntry = null;
}
