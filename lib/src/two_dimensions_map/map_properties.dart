class MapProperties {
  final double tileWidth;
  final double tileHeight;

  final int tilesOx;
  final int tilesOy;

  final double offsetOx;
  final double offsetOy;

  const MapProperties({
    required this.tileWidth,
    required this.tileHeight,
    required this.tilesOx,
    required this.tilesOy,
    this.offsetOx = 0,
    this.offsetOy = 0,
  });
}
