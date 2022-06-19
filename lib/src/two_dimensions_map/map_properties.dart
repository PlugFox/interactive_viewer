class MapProperties {
  final double tileWidth;
  final double tileHeight;

  final int tilesOx;
  final int tilesOy;

  final int tilesOxDisplayed;
  final int tilesOyDisplayed;

  late final double offsetOx;
  late final double offsetOy;

  MapProperties({
    required this.tileWidth,
    required this.tileHeight,
    required this.tilesOx,
    required this.tilesOy,
    required this.tilesOxDisplayed,
    required this.tilesOyDisplayed,
    double? offsetOx,
    double? offsetOy,
  }) {
    if (offsetOx != null) {
      this.offsetOx = offsetOx;
    } else {
      this.offsetOx = (tilesOxDisplayed * tileWidth * (-1)) / 4;
    }
    if (offsetOy != null) {
      this.offsetOy = offsetOy;
    } else {
      this.offsetOy = (tilesOyDisplayed * tileHeight * (-1)) / 4;
    }
  }
}
