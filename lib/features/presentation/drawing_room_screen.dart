import 'package:flutter/material.dart';
import 'package:coloring_book/core/theme/app_color.dart';
import 'package:coloring_book/features/model/drawing_point.dart';

class DrawingRoomScreen extends StatefulWidget {
  const DrawingRoomScreen({Key? key}) : super(key: key);

  @override
  _DrawingRoomScreenState createState() => _DrawingRoomScreenState();
}

class _DrawingRoomScreenState extends State<DrawingRoomScreen> {
  var availableColor = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;

  DrawingPoint? currentDrawingPoint;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: Stack(
            children: [
              //---------------------------------------------------------- Canvas --------------------------------------------
              Container(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    setState(() {
                      currentDrawingPoint = DrawingPoint(
                        id: DateTime.now().microsecondsSinceEpoch,
                        offsets: [
                          details.localPosition,
                        ],
                        color: selectedColor,
                        width: selectedWidth,
                      );

                      if (currentDrawingPoint == null) return;
                      drawingPoints.add(currentDrawingPoint!);
                      historyDrawingPoints = List.of(drawingPoints);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      if (currentDrawingPoint == null) return;

                      currentDrawingPoint = currentDrawingPoint?.copyWith(
                        offsets: currentDrawingPoint!.offsets
                          ..add(details.localPosition),
                      );
                      drawingPoints.last = currentDrawingPoint!;
                      historyDrawingPoints = List.of(drawingPoints);
                    });
                  },
                  onPanEnd: (_) {
                    currentDrawingPoint = null;
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(
                      drawingPoints: drawingPoints,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ),
              ),

              //----------------------------------------------------- color pallet --------------------------------------------
              Positioned(
                top: isLandscape ? 16 : MediaQuery.of(context).padding.top,
                left: isLandscape ? 16 : 0,
                right: isLandscape ? 16 : 0,
                child: SizedBox(
                  height: isLandscape ? 80 : 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableColor.length,
                    separatorBuilder: (_, __) {
                      return const SizedBox(width: 8);
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = availableColor[index];
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: availableColor[index],
                            shape: BoxShape.circle,
                          ),
                          foregroundDecoration: BoxDecoration(
                            border: selectedColor == availableColor[index]
                                ? Border.all(
                                    color: AppColor.primaryColor, width: 4)
                                : null,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              //---------------------------------------------------- pencil size ----------------------
              Positioned(
                top: isLandscape
                    ? MediaQuery.of(context).padding.top + 16
                    : MediaQuery.of(context).padding.top + 80,
                right: isLandscape ? 0 : 0,
                bottom: isLandscape ? 150 : 0,
                child: RotatedBox(
                  quarterTurns: isLandscape ? 3 : 0,
                  child: Slider(
                    value: selectedWidth,
                    min: 1,
                    max: 20,
                    onChanged: (value) {
                      setState(() {
                        selectedWidth = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "Finish",
                onPressed: () {
                  // Add the finish drawing logic here
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.check),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: "Undo",
                onPressed: () {
                  if (drawingPoints.isNotEmpty &&
                      historyDrawingPoints.isNotEmpty) {
                    setState(() {
                      drawingPoints.removeLast();
                    });
                  }
                },
                child: const Icon(Icons.undo),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: "Redo",
                onPressed: () {
                  setState(() {
                    if (drawingPoints.length < historyDrawingPoints.length) {
                      final index = drawingPoints.length;
                      drawingPoints.add(historyDrawingPoints[index]);
                    }
                  });
                },
                child: const Icon(Icons.redo),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..color = drawingPoint.color
        ..isAntiAlias = true
        ..strokeWidth = drawingPoint.width
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < drawingPoint.offsets.length; i++) {
        var notLastOffset = i != drawingPoint.offsets.length - 1;

        if (notLastOffset) {
          final current = drawingPoint.offsets[i];
          final next = drawingPoint.offsets[i + 1];
          canvas.drawLine(current, next, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
