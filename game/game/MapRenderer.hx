package game;

class MapRenderer {
  static final TURN_TIME = 25;
  
  public var activePlayer:Player;
  public var camX:Float = 50;
  public var camY:Float = 100;
  public var camAngle:Float = 0;
  public var range:Array<Tile> = [];
  public var actions:Array<UnitAction> = [];
  public var rangeColour:Int = 0;
  public var hideNone:Bool = true;
  
  public var hpBarShow = new Bitween(15, true);
  
  public var captureBar = {
       show: new Bitween(15, false)
      ,target: (null:Building)
      ,prevNum: 1
      ,nextNum: 0
      ,cycleProg: 1
      ,buf: Platform.createBitmap(11, 11, 0)
      ,attacker: (null:Player)
      ,capture: false
    };
  
  public var camXI:Int = 50;
  public var camYI:Int = 100;
  
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
    captureBar.show.tick();
    
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
      ab.blitAlpha(unit.unitBitmap(), bx, by);
      
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
    }
    for (sti in tilesSorted) {
      var tile = map.tiles[sti];
      if (tile != null) {
        if (hideNone && tile.terrain == TTNone) continue;
        var screenPos = tile.position.toPixel(camAngle);
        var rangeIndex = range.indexOf(tile);
        var visible = activePlayer == null ? true : activePlayer.vision[sti];
        if (rangeIndex != -1) screenPos.y--;
        if (tile.buildings.length > 0) {
          var building = tile.buildings[0];
          ab.blitAlpha(
               building.buildingBitmap()
              ,screenPos.x - 5 + camXI
              ,screenPos.y - 20 + camYI
            );
        } else {
          ab.blitAlpha(
               tile.tileBitmap()
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
        if (visible) {
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
        } else {
          ab.blitAlpha(GSGame.B_FOW, screenPos.x + camXI, screenPos.y + camYI - 3);
        }
        tile.offsetUnits = [];
        if (tile.terrain == TTWater && FM.prng.nextMod(100) == 0) tile.variation = FM.prng.nextMod(tile.terrain.variations());
      }
    }
    
    // actions
    for (a in actions) {
      var frame = -1;
      var tilePosition = (switch (a) {
          case Attack(target): frame = 0; target.tile.position;
          case Repair(target): frame = 1; target.tile.position;
          case Capture(target): frame = 2; target.tile.position;
          case CaptureUnit(target): frame = 2; target.tile.position;
          case AttackNoDamage(target): frame = 3; target.tile.position;
          case Sacrifice: continue;
        });
      var screenPos = tilePosition.toPixel(camAngle);
      if (frame == -1) continue;
      ab.blitAlpha(
           GSGame.B_ACTIONS[frame]
          ,screenPos.x + camXI
          ,screenPos.y + camYI
        );
    }
    
    if (!captureBar.show.isOff) {
      var textOffX = 0;
      var capFrame = GSGame.B_CAPTURE[captureBar.capture ? 0 : 1];
      var text = (switch [captureBar.prevNum, captureBar.capture] {
          case [0, true]: textOffX = 1; "CAPTURED!";
          case [_, true]: "CAPTURING";
          case [0, false]: textOffX = 1; "RAZED!";
          case [_, false]: "RAZING";
        });
      
      var screenPos = captureBar.target.tile.position.toPixel(camAngle);
      screenPos.x += camXI;
      screenPos.y += camYI;
      var barH = Timing.quartInOut.getI(captureBar.show.valueF, capFrame.height);
      var barY = capFrame.height - barH;
      screenPos.y += barY;
      
      ab.blitAlphaRect(
           capFrame
          ,screenPos.x + 4, screenPos.y - 30
          ,0, 0
          ,Timing.quartInOut.getI(captureBar.show.valueF, capFrame.width)
          ,barH
        );
      captureBar.buf.fill(0);
      var numY = Timing.quartInOut.getI((captureBar.cycleProg / 16), 13);
      Text.render(captureBar.buf, 2, 1 + numY, '${Text.tp(captureBar.attacker)}${captureBar.prevNum}');
      Text.render(captureBar.buf, 2, 1 - 13 + numY, '${Text.tp(captureBar.attacker)}${captureBar.nextNum}');
      ab.blitAlpha(captureBar.buf, screenPos.x + 5, screenPos.y - 29);
      
      Text.render(
           ab
          ,screenPos.x + 16 + textOffX
          ,screenPos.y - 27
          ,Text.tp(captureBar.attacker, false) + text.substr(0, captureBar.show.value)
        );
      
      if (captureBar.cycleProg != 0 && captureBar.show.isOn) {
        captureBar.cycleProg++;
        if (captureBar.cycleProg >= 16) {
          captureBar.prevNum = captureBar.nextNum;
          captureBar.cycleProg = 0;
        }
      }
    }
  }
}
