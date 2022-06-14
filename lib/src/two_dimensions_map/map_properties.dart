class MapProperties {
  final double tileWidth;
  final double tileHeight;

  final int tilesOx;
  final int tilesOy;

  final int tilesOxDisplayed;
  final int tilesOyDisplayed;

  final double offsetOx;
  final double offsetOy;

  const MapProperties({
    required this.tileWidth,
    required this.tileHeight,
    required this.tilesOx,
    required this.tilesOy,
    required this.tilesOxDisplayed,
    required this.tilesOyDisplayed,
    this.offsetOx = 0,
    this.offsetOy = 0,
  });
}
