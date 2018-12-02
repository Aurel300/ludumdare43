package game;

class MapRenderer {
  static final TURN_TIME = 25;
  
  public var camX:Float = 50;
  public var camY:Float = 100;
  public var camAngle:Float = 0;
  public var range:Array<Tile> = [];
  public var actions:Array<UnitAction> = [];
  public var rangeColour:Int = 0;
  public var hpBarShow = new Bitween(15, true);
  
  var camXI:Int = 50;
  var camYI:Int = 50;
  var rangeT:Int = 0;
  var map:Map;
  var prevAngle:Int = 0;
  var deltaAngle:Int = 0;
  var nextAngleProg:Float = 0;
  var tilesSorted:Vector<Int>;
  
  public function new(map:Map) {
    this.map = map;
    sortTiles(true);
  }
  
  public function turnAngle(delta:Int):Void {
    if (nextAngleProg != 0) return;
    deltaAngle = delta;
    nextAngleProg = 1;
  }
  
  public function mouseToTp(mx:Int, my:Int):TilePosition {
    return {
         x: mx - camXI - 11
        ,y: my - camYI - 6
      }.fromPixel(camAngle);
  }
  
  public inline function mouseToTile(mx:Int, my:Int):Null<Tile> {
    return map.get(mouseToTp(mx, my));
  }
  
  public function sortTiles(?regen:Bool = false):Void {
    if (regen) {
      tilesSorted = new Vector(map.tiles.length);
      for (i in 0...map.tiles.length) tilesSorted[i] = i;
    }
    function sort(ai:Int, bi:Int):Int {
      var posA = map.tiles[ai].position.toPixel(camAngle);
      var posB = map.tiles[bi].position.toPixel(camAngle);
      return posA.y - posB.y;
    }
    tilesSorted.sort(sort);
  }
  
  public function renderMap(
     ab:Bitmap
    ,mx:Int, my:Int
  ) {
    // tickers
    hpBarShow.tick();
    
    // update camera
    
    if (nextAngleProg != 0) {
      camAngle = (6.0 + prevAngle + deltaAngle * Timing.quartInOut.getF(nextAngleProg / TURN_TIME)) * 60.0;
      nextAngleProg++;
      if (nextAngleProg >= TURN_TIME) {
        prevAngle = (6 + prevAngle + deltaAngle) % 6;
        camAngle = prevAngle * 60.0;
        nextAngleProg = 0;
      }
      sortTiles();
    }
    
    camXI = camX.floor();
    camYI = camY.floor();
    
    var rangeBorders = null;
    if (range.length > 0) {
      rangeT++;
      rangeT %= 3 * 8;
      rangeBorders = range.map(tile -> [ for (n in tile.neighboursAll) n == null || range.indexOf(n) == -1 ]);
    }
    
    function renderUnit(unit:Unit, tile:Tile, screenPos:TilePosition):Void {
      var bx = screenPos.x + unit.offX.round() - 5 + camXI;
      var by = screenPos.y + unit.offY.round() - 14 - tile.height + camYI;
      ab.blitAlpha(
           GSGame.B_UNITS[(cast unit.type:Int)][unit.owner.playerColour()]
          ,bx
          ,by
        );
      
      var full = (range.indexOf(unit.tile) != -1 || unit.actionRelevant);
      var cx = bx + 7;
      var cy = by - (full ? 4 : 2);
      var segH = full ? 12 : 6;
      var segY = Timing.quartInOut.getI(hpBarShow.valueF, segH);
      for (i in 0...unit.stats.maxHP) {
        var which = unit.stats.HP >= i + 1 ? 1 : 0;
        if (full && which == 0 && (unit.stats.HP + ((unit.hurtTimer + 7) >> 3)) >= i + 1) {
          which = 2;
        }
        ab.blitAlphaRect(GSGame.B_HP_BAR[which + (full ? 2 : 0)], cx, cy + segH - segY, 0, 0, segY, segH);
        cx += full ? 4 : 3;
      }
      
      //ab.fillRect(bx + 7, by - 2, unit.stats.maxHP * 2 + 2, 4, GSGame.B_PAL[31]);
      //if (unit.stats.HP > 0) ab.fillRect(bx + 8, by - 1, unit.stats.HP * 2, 2, GSGame.B_PAL[29]);
      //ab.fillRect(bx + 7, by - 5, unit.stats.maxMP * 2 + 2, 3, GSGame.B_PAL[123]);
      //if (unit.stats.MP > 0) ab.fillRect(bx + 8, by - 4, unit.stats.MP * 2, 2, GSGame.B_PAL[130]);
    }
    for (sti in tilesSorted) {
    //for (y in 0...map.height) for (x in 0...map.width) {
      //var tile = map.getXY(camAngle.withinF(15, 195) ? x : map.width - x - 1, camAngle.withinF(0, 120) || camAngle >= 300 ? y : map.height - y - 1);
      //var ax = x;
      //var ay = y;
      //switch (prevAngle) {
      //  case 1: 
      //  case 2: x = map.width - x - 1;
      //  case _: 
      //}
      //var tile = map.getXY(ax, ay);
      var tile = map.tiles[sti];
      if (tile != null) {
        var screenPos = tile.position.toPixel(camAngle);
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
          for (rb in 0...6) if (borders[(6 + rb - prevAngle) % 6]) {
            ab.blitAlpha(
                 GSGame.B_RANGE_BORDERS[(rangeT >> 3) + 1][rb][rangeColour]
                ,screenPos.x + camXI + GSGame.RANGE_BORDERS_X[rb]
                ,screenPos.y + camYI + GSGame.RANGE_BORDERS_Y[rb]
              );
          }
        }
        for (unit in tile.units) {
          if (unit.hurtTimer > 0) unit.hurtTimer--;
          if (unit.displayTile != null) {
            unit.displayTile.offsetUnits.push(unit);
          } else {
            renderUnit(unit, tile, screenPos);
          }
        }
        for (unit in tile.offsetUnits) {
          renderUnit(unit, unit.tile, unit.tile.position.toPixel(camAngle));
        }
        tile.offsetUnits = [];
        if (tile.terrain == TTWater && FM.prng.nextMod(100) == 0)
        tile.variation = FM.prng.nextMod(tile.terrain.variations());
      }
    }
    
    for (a in actions) {
      var type = -1;
      var tilePosition = (switch (a) {
          case Attack(target): type = 0; target.tile.position;
          case Repair(target): type = 1; target.tile.position;
          case Capture(target): type = 2; target.tile.position;
        });
      var screenPos = tilePosition.toPixel(camAngle);
      if (type == -1) continue;
      ab.blitAlpha(
           GSGame.B_ACTIONS[type]
          ,screenPos.x + camXI
          ,screenPos.y + camYI
        );
    }
  }
}
