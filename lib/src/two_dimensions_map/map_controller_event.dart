import 'dart:math';

enum MapEventType {
  unknown,
  centerToPoint,
  setZoom,
}

class MapControllerEvent {
  final MapEventType eventType;
  final Object data;

  const MapControllerEvent({
    required this.eventType,
    required this.data,
  });

  MapControllerEvent.centerToPoint({required Point<int> point})
      : eventType = MapEventType.centerToPoint,
        data = point;

  MapControllerEvent.zoom({required double scale})
      : eventType = MapEventType.setZoom,
        data = scale;
}
