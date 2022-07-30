import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RaytraceExample extends FlameGame
    with
        HasCollisionDetection,
        TapDetector,
        MouseMovementDetector,
        TapDetector {
  static const description = '''
In this example the raytrace functionality is showcased, if you move the mouse
around the canvas, rays and their reflections will be rendered.
  ''';

  Ray2? ray;
  Ray2? reflection;
  Vector2? origin;
  bool isOriginCasted = false;
  Paint paint = Paint()..color = Colors.amber.withOpacity(0.2);

  static const numberOfRays = 1;
  final List<Ray2> rays = [];
  final List<RaycastResult<ShapeHitbox>> results = [];

  late Path path;
  @override
  Future<void> onLoad() async {
    final paint = BasicPalette.gray.paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    addAll([
      ScreenHitbox(),
      CircleComponent(
        position: Vector2(100, 100),
        radius: 50,
        paint: paint,
        children: [CircleHitbox()],
      ),
      CircleComponent(
        position: Vector2(150, 500),
        radius: 50,
        paint: paint,
        anchor: Anchor.center,
        children: [CircleHitbox()],
      ),
      CircleComponent(
        position: Vector2(150, 500),
        radius: 150,
        paint: paint,
        anchor: Anchor.center,
        children: [CircleHitbox()],
      ),
      RectangleComponent(
        position: Vector2.all(300),
        size: Vector2.all(100),
        paint: paint,
        children: [RectangleHitbox()],
      ),
      RectangleComponent(
        position: Vector2.all(500),
        size: Vector2(100, 200),
        paint: paint,
        children: [RectangleHitbox()],
      ),
      CircleComponent(
        position: Vector2(650, 275),
        radius: 50,
        paint: paint,
        anchor: Anchor.center,
        children: [CircleHitbox()],
      ),
      RectangleComponent(
        position: Vector2(550, 200),
        size: Vector2(200, 150),
        paint: paint,
        children: [RectangleHitbox()],
      ),
      RectangleComponent(
        position: Vector2(900, 200),
        size: Vector2(200, 150),
        paint: paint,
        angle: tau / 6,
        children: [RectangleHitbox()],
      ),
    ]);
  }

  @override
  void onTapDown(TapDownInfo info) {
    final origin = info.eventPosition.game;
    isOriginCasted = origin == this.origin;
    this.origin = origin;
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final origin = info.eventPosition.game;
    isOriginCasted = origin == this.origin;
    this.origin = origin;
  }

  final Ray2 _ray = Ray2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    if (origin != null && !isOriginCasted) {
      _ray.origin.setFrom(origin!);
      _ray.direction
        ..setValues(-1, 1)
        ..normalize();
      const angle = tau / numberOfRays;
      for (var i = 0; i < numberOfRays; i++) {
        _ray.direction.rotate(i * angle);
        _ray.updateInverses();
        collisionDetection.raytrace(
          _ray,
          maxDepth: 1000,
          out: results,
        );
      }
      isOriginCasted = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (origin != null) {
      renderResult(canvas, origin!, results, paint);
    }
  }

  void renderResult(
    Canvas canvas,
    Vector2 origin,
    List<RaycastResult<ShapeHitbox>> results,
    Paint paint,
  ) {
    var originOffset = origin.toOffset();
    for (final result in results) {
      if (!result.isActive) {
        continue;
      }
      final intersectionPoint = result.intersectionPoint!.toOffset();
      canvas.drawLine(
        originOffset,
        intersectionPoint,
        paint,
      );
      originOffset = intersectionPoint;
    }
  }
}
