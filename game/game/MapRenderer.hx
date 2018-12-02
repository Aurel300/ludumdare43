package game;

class MapRenderer {
  public var camX:Float = 50;
  public var camY:Float = 100;
  public var range:Array<Tile> = [];
  
  var camXI:Int = 50;
  var camYI:Int = 50;
  var rangeT:Int = 0;
  var map:Map;
  
  static var RANGE_BORDERS_X = [0, 5, 0, 17, 5, 17];
  static var RANGE_BORDERS_W = [6, 12, 6, 6, 12, 6];
  static var RANGE_BORDERS_Y = [0, 0, 6, 0, 6, 6];
  
  public function new(map:Map) {
    this.map = map;
  }
  
  public function mouseToTp(mx:Int, my:Int):TilePosition {
    return {
         x: mx - camXI - 11
        ,y: my - camYI - 6
      }.pixelToAxial().axialToCube().cubeRound().cubeToTp();
  }
  
  public inline function mouseToTile(mx:Int, my:Int):Null<Tile> {
    return map.get(mouseToTp(mx, my));
  }
  
  public function renderMap(
     ab:Bitmap
    ,mx:Int, my:Int
  ) {
    // update camera
    
    camXI = camX.floor();
    camYI = camY.floor();
    
    var rangeUnit = null;
    var rangeBorders = null;
    
    var mouseTile = mouseToTile(mx, my);
    if (mouseTile != null && mouseTile.units.length > 0) {
      //range = [mouseTile];
      //rangeBorders = [[ for (i in 0...6) true ]];
      rangeUnit = mouseTile.units[0];
    }
    
    if (rangeUnit != null) {
      range = rangeUnit.accessibleTiles;
    }
    
    if (range.length > 0) {
      rangeT++;
      rangeT %= 3 * 8;
      rangeBorders = range.map(tile -> [ for (n in tile.neighboursAll) n == null || range.indexOf(n) == -1 ]);
    }
    
    for (y in 0...map.height) for (rx in 0...map.width) {
      var tile = map.getXY(map.width - rx - 1, y);
      if (tile != null) {
        var screenPos = tile.position.toPixel();
        var rangeIndex = range.indexOf(tile);
        if (rangeIndex != -1) screenPos.y--;
        if (tile.buildings.length > 0) {
          var building = tile.buildings[0];
          ab.blitAlpha(
               GSGame.B_BUILDINGS[(cast building.type:Int)][building.owner.playerColour()]
              ,screenPos.x - 5 + camXI
              ,screenPos.y - 20 + camYI
            );
        } else {
          ab.blitAlpha(
               GSGame.B_TERRAIN[(cast tile.terrain:Int)][tile.variation]
              ,screenPos.x + camXI
              ,screenPos.y - 6 + camYI
            );
        }
        var rangeIndex = range.indexOf(tile);
        if (rangeIndex != -1) {
          var borders = rangeBorders[rangeIndex];
          for (rb in 0...6) if (borders[rb]) {
            ab.blitAlpha(
                 GSGame.B_RANGE_BORDERS[(rangeT >> 3) + 1][rb]
                ,screenPos.x + camXI + GSGame.RANGE_BORDERS_X[rb]
                ,screenPos.y + camYI + GSGame.RANGE_BORDERS_Y[rb]
              );
          }
        }
        for (unit in tile.units) {
          ab.blitAlpha(
               GSGame.B_UNITS[(cast unit.type:Int)][unit.owner.playerColour()]
              ,screenPos.x - 5 + camXI
              ,screenPos.y - 14 - tile.height + camYI
            );
        }
        if (tile.terrain == TTWater && FM.prng.nextMod(100) == 0)
        tile.variation = FM.prng.nextMod(tile.terrain.variations());
      }
    }
  }
}
