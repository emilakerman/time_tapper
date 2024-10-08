import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_tapper/src/Tapping/ArcAnimation/Presentation/arc_animation.dart';
import 'package:time_tapper/src/Tapping/AutoTapper/Presentation/auto_tap_icon.dart';
import 'package:time_tapper/src/Tapping/DoubleTap/Presentation/double_tap_icon.dart';
import 'package:time_tapper/src/Tapping/GambleTap/Presentation/gamble_tap_icon.dart';
import 'package:time_tapper/src/Tapping/increments.dart';
import 'package:time_tapper/src/Tapping/point_fixer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

int points = 0;
bool doubleTapActivated = false;
bool gambleTapActivated = false;
bool startAnimation = false;
bool autoClickerEnabled = false;
Color? autoClickerIconColor;
Increments increments = const Increments();

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue[100]!,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 70),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      points >= 10
                          ? InkWell(
                              onTap: () => setState(() {
                                    if (doubleTapActivated) return;
                                    startAnimation = false;
                                    doubleTapActivated = true;
                                  }),
                              child: DoubleTapIcon(
                                  color: doubleTapActivated
                                      ? Colors.transparent.withOpacity(0.2)
                                      : null))
                          : DoubleTapIcon.disabled(context),
                      points >= 40
                          ? InkWell(
                              onTap: () => setState(() {
                                    if (gambleTapActivated) return;
                                    gambleTapActivated = true;
                                    points = increments.gamblePoints(points);
                                  }),
                              child: GambleTapIcon(
                                  color: gambleTapActivated
                                      ? Colors.transparent.withOpacity(0.2)
                                      : null))
                          : GambleTapIcon.disabled(context),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const HeaderText(),
                    Stack(
                      children: [
                        Cube(
                            key: _cubeKey,
                            click: () {
                              setState(() {
                                startAnimation = true;
                                points = increments.increment(
                                    points, doubleTapActivated);
                              });
                            }),
                        ArcAnimation(
                          clicked: startAnimation,
                          isReversed: false,
                        ),
                        if (doubleTapActivated)
                          ArcAnimation(
                            clicked: startAnimation,
                            isReversed: true,
                          ),
                      ],
                    ),
                    PointsWidget(points: points),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      points >= 20
                          ? InkWell(
                              onTap: () {
                                autoClickerEnabled = !autoClickerEnabled;
                                if (!autoClickerEnabled) {
                                  setState(() {
                                    autoClickerIconColor = null;
                                  });
                                } else {
                                  setState(() {
                                    autoClickerIconColor =
                                        Colors.transparent.withOpacity(0.2);
                                  });
                                }
                                autoClicker();
                              },
                              child: AutoTapIcon(color: autoClickerIconColor),
                            )
                          : AutoTapIcon.disabled(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final GlobalKey<_CubeState> _cubeKey = GlobalKey<_CubeState>();

  void autoClicker() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!autoClickerEnabled) {
        timer.cancel();
        return;
      }
      setState(() {
        _cubeKey.currentState?._animateClock();
        points = increments.increment(points, doubleTapActivated);
      });
    });
  }
}

class HeaderText extends StatelessWidget {
  const HeaderText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "",
      style: TextStyle(
        color: Colors.white,
        fontSize: 25,
      ),
    );
  }
}

class PointsWidget extends StatefulWidget {
  const PointsWidget({
    this.points,
    super.key,
  });
  final int? points;
  @override
  State<PointsWidget> createState() => _PointsWidgetState();
}

class _PointsWidgetState extends State<PointsWidget> {
  PointFixer pointFixer = PointFixer();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Text(
              pointFixer.formatPoints(widget.points!),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = Colors.black,
              ),
            ),
            widget.points! >= 1000000
                ? Text(
                    widget.points.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = Colors.black,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        Column(
          children: [
            Text(
              pointFixer.formatPoints(widget.points!),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            widget.points! >= 1000000
                ? Text(
                    widget.points.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}

class Cube extends StatefulWidget {
  const Cube({required this.click, super.key});
  final VoidCallback click;
  @override
  State<Cube> createState() => _CubeState();
}

class _CubeState extends State<Cube> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100))
    ..addListener(() {
      setState(() {});
    });
  late final animation = Tween<Matrix4>(
          begin: Matrix4.translationValues(0, 15, 0), end: Matrix4.identity())
      .animate(controller);

  double size = 200;

  void _animateClock() {
    controller.forward().whenComplete(() {
      controller.reverse();
      size = 200;
    });
    setState(() {
      size = size + 10;
    });
  }

  void _startAnimation() {
    _animateClock();
    widget.click();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          _startAnimation();
        },
        child: AnimatedContainer(
          transform: animation.value,
          duration: controller.duration!,
          child: Image.asset(
            'assets/clickthisguy.png',
            height: size,
            width: size,
          ),
        ),
      ),
    );
  }
}
