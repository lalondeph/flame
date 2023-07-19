// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:examples/stories/bridge_libraries/forge2d/sprite_body_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class DominoExample extends Forge2DGame with TapDetector {
  static const description = '''
    In this example we can see some domino tiles lined up.
    If you tap on the screen a pizza is added which can tip the tiles over and
    cause a chain reaction. 
  ''';

  DominoExample() : super(gravity: Vector2(0, 10.0));

  late Image pizzaImage;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(this);
    world.addAll(boundaries);

    const numberOfRows = 7;
    for (var i = 0; i < numberOfRows - 2; i++) {
      world.add(Platform(Vector2(0.0, 5.0 * i)));
    }

    const numberPerRow = 25;
    for (var i = 0; i < numberOfRows; ++i) {
      for (var j = 0; j < numberPerRow; j++) {
        final position = Vector2(
          -14.75 + j * (29.5 / (numberPerRow - 1)),
          -12.7 + 5 * i,
        );
        world.add(DominoBrick(position));
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    final position = screenToWorld(info.eventPosition.widget);
    world.add(Pizza(position));
  }
}

class Platform extends BodyComponent {
  final Vector2 position;

  Platform(this.position);

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(14.8, 0.125);
    final fixtureDef = FixtureDef(shape);

    final bodyDef = BodyDef(position: position);
    final body = world.createBody(bodyDef);
    return body..createFixture(fixtureDef);
  }
}

class DominoBrick extends BodyComponent {
  final Vector2 position;

  DominoBrick(this.position);

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(0.125, 2.0);
    final fixtureDef = FixtureDef(
      shape,
      density: 25.0,
      restitution: 0.4,
      friction: 0.5,
    );

    final bodyDef = BodyDef(type: BodyType.dynamic, position: position);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
