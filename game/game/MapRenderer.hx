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
          ab.blitAlphaRect(GSGame.B_GAME, screenPos.x + camXI - 5, screenPos.y - 20 + camYI, 32, 72 + (cast tile.buildings[0].type:Int) * 32, 32, 32);
        } else {
          ab.blitAlphaRect(GSGame.B_GAME, screenPos.x + camXI, screenPos.y - 6 + camYI, (cast tile.terrain:Int) * 24, tile.variation * 18, 24, 18);
        }
        var rangeIndex = range.indexOf(tile);
        if (rangeIndex != -1) {
          var borders = rangeBorders[rangeIndex];
          for (rb in 0...6) if (borders[rb]) {
            ab.blitAlphaRect(
               GSGame.B_GAME
              ,screenPos.x + camXI + RANGE_BORDERS_X[rb]
              ,screenPos.y + camYI + RANGE_BORDERS_Y[rb]
              ,168 + RANGE_BORDERS_X[rb]
              ,((rangeT >> 3) + 1) * 16 + RANGE_BORDERS_Y[rb]
              ,RANGE_BORDERS_W[rb]
              ,6);
          }
        }
        for (unit in tile.units) {
          ab.blitAlphaRect(GSGame.B_GAME, screenPos.x + camXI - 5, screenPos.y - 14 - tile.height + camYI, 0, 80 + (cast unit.type:Int) * 24, 32, 24);
        }
        if (tile.terrain == TTWater && FM.prng.nextMod(100) == 0)
        tile.variation = FM.prng.nextMod(tile.terrain.variations());
      }
    }
  }
}
