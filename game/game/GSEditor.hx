package game;

using Lambda;

class GSEditor extends JamState {
  public static var I:GSEditor;
  public static var map:Map;
  
  var mapRenderer:MapRenderer;
  var mode:EditorMode = EMTerrain;
  var selectedTerrain:Terrain = TTPlain;
  var selectedBuilding:BuildingType = BTTempleTron;
  var selectedUnit:UnitType = Bull;
  var mouseHeld:Bool = false;
  var brush:Int = 0;
  var selectedOwner:Player = null;
  var players:Array<Player>;
  
  function mkTile(x:Int, y:Int):Tile return new Tile(selectedTerrain, FM.prng.nextMod(selectedTerrain.variations()), {x: x, y: y}, map);
  
  public function new(app) {
    I = this;
    super("editor", app);
    players = [new Player("P1", Juggernauts, null), new Player("P2", Juggernauts, null)];
    players[0].colourIndex = 1;
    players[1].colourIndex = 2;
  }
  
  override public function to():Void {
    if (map == null) {
      map = new Map(players, null);
      map.width = map.height = 2;
      map.tiles = new Vector(map.width * map.height);
      for (i in 0...map.tiles.length) map.tiles[i] = mkTile(i % map.width, (i / map.width).floor());
    }
    mapRenderer = new MapRenderer(map);
  }
  
  override public function keyUp(k:Key):Void {
    switch (k) {
      case KeyA // add row / column
        | KeyD: // remove row / column
      var add = (k == KeyA);
      var addNP = add ? 1 : -1;
      var xDir = (1.negposI(ak(ArrowLeft), ak(ArrowRight)));
      var yDir = (1.negposI(ak(ArrowUp), ak(ArrowDown)));
      if ((xDir != 0) == (yDir != 0)) return;
      if (xDir != 0) {
        if (!add && map.width <= 1) return;
        var ti = 0;
        map.tiles = Vector.fromArrayCopy([ for (y in 0...map.height) {
            var line = [ for (x in 0...map.width) map.tiles[ti++] ];
            if (add) line.insert(xDir == -1 ? 0 : map.width, mkTile(xDir == -1 ? -1 : map.width, y));
            else line.splice(xDir == -1 ? 0 : map.width - 1, 1);
            line;
          }].flatten());
        map.width += addNP;
        if (xDir == -1) {
          for (t in map.tiles) t.position.x += addNP;
          mapRenderer.camX -= 18 * addNP;
          mapRenderer.camY -= -6 * addNP;
        }
      } else {
        if (!add && map.height <= 1) return;
        var ti = 0;
        var lines = [ for (y in 0...map.height) [ for (x in 0...map.width) map.tiles[ti++] ]];
        if (add) lines.insert(yDir == -1 ? 0 : lines.length, [ for (x in 0...map.width) mkTile(x, yDir == -1 ? -1 : map.height) ]);
        else lines.splice(yDir == -1 ? 0 : lines.length - 1, 1);
        map.tiles = Vector.fromArrayCopy(lines.flatten());
        map.height += addNP;
        if (yDir == -1) {
          for (t in map.tiles) t.position.y += addNP;
          mapRenderer.camX -= 12 * addNP;
          mapRenderer.camY -= 12 * addNP;
        }
      }
      mapRenderer.sortTiles(true);
      // select terrain, building, or unit
      case KeyZ | KeyX | KeyC | KeyV | KeyB | KeyN:
      switch (mode) {
        case EMTerrain: selectedTerrain = (switch (k) {
            case KeyZ: TTPlain;
            case KeyX: TTDesert;
            case KeyC: TTHill;
            case KeyV: TTMountain;
            case KeyB: TTWater;
            case KeyN: TTVoid;
            case _: return;
          });
        case EMBuilding: selectedBuilding = (switch (k) {
            case KeyZ: BTTempleTron;
            case KeyX: BTFactoreon;
            case KeyC: BTForge;
            case KeyV: BTFortress;
            case KeyB: BTShrine;
            case _: return;
          });
        case EMUnit: selectedUnit = (switch (k) {
            case KeyZ: Bull;
            case KeyX: Chamois;
            case KeyC: BombardierAnt;
            case KeyV: Bat;
            case KeyB: Monkey;
            case _: return;
          });
      }
      // select brush or player
      case KeyI: if (mode == EMTerrain) brush = 0; else selectedOwner = null;
      case KeyO: if (mode == EMTerrain) brush = 1; else selectedOwner = players[0];
      case KeyP: if (mode == EMTerrain) brush = 2; else selectedOwner = players[1];
      case KeyT: // exporT
      var data = map.encode();
      var b64 = haxe.crypto.Base64.encode(data);
      untyped __js__("navigator.clipboard.writeText({0})", b64);
      case KeyY: // Ymport
      var b64 = js.Browser.window.prompt("import data (or empty)");
      if (b64.length < 4 * 3) return;
      var data = (try {
          haxe.crypto.Base64.decode(b64);
        } catch (e:Dynamic) {
          trace("decode error", e);
          return;
        });
      map.decode(players, data);
      // toggle terrain / building mode
      case Space: mode = (switch (mode) {
          case EMTerrain: EMUnit;
          case EMBuilding: EMTerrain;
          case EMUnit: EMBuilding;
        });
      case KeyR: // restore HP / MP for units
      for (tile in map.tiles) for (unit in tile.units) {
        unit.stats.HP = unit.stats.maxHP;
        unit.stats.MP = unit.stats.maxMP;
      }
      case KeyQ: // test in game
      GSGame.I.initMap(map.encode());
      st("game");
      case _:
    }
  }
  
  override public function tick():Void {
    // controls
    if (!ak(ArrowLeft) && !ak(ArrowRight) && !ak(ArrowUp) && !ak(ArrowDown)) {
      mapRenderer.camX -= 3.negposF(ak(KeyA), ak(KeyD));
      mapRenderer.camY -= 3.negposF(ak(KeyW), ak(KeyS));
    }
    var selectionRange = (mode == EMTerrain ? brush : 0);
    
    // rendering
    ab.fill(Colour.BLACK);
    var mouseTile = mapRenderer.mouseToTile(app.mouse.x, app.mouse.y);
    if (mouseTile == null) mapRenderer.range = [];
    else mapRenderer.range = [ for (t in map.tiles) if (t.position.distance(mouseTile.position) <= selectionRange) t ];
    
    mapRenderer.renderMap(ab, app.mouse.x, app.mouse.y);
    
    // UI
    switch (mode) {
      case EMTerrain:
      for (i in 0...6) {
        ab.blitAlpha(
             GSGame.B_TERRAIN[(cast i:Terrain)][0]
            ,8 + i * 18
            ,300 - 20 - ((cast i:Terrain) == selectedTerrain ? 4 : 0)
          );
      }
      case EMBuilding:
      for (i in 0...5) {
        ab.blitAlpha(
             GSGame.B_BUILDINGS[(cast i:BuildingType)][selectedOwner.playerColour()]
            ,3 + i * 18
            ,300 - 34 - ((cast i:BuildingType) == selectedBuilding ? 4 : 0)
          );
      }
      case EMUnit:
      for (i in 0...5) {
        ab.blitAlpha(
             GSGame.B_UNITS[(cast i:UnitType)][selectedOwner.playerColour()]
            ,3 + i * 18
            ,300 - 26 - ((cast i:UnitType) == selectedUnit ? 4 : 0)
          );
      }
    }
  }
  
  function brushTick():Void {
    var tile = mapRenderer.mouseToTile(app.mouse.x, app.mouse.y);
    if (tile == null) return;
    switch (mode) {
      case EMTerrain:
      for (t in map.tiles) {
        if (t.position.distance(tile.position) <= brush) {
          if (t.buildings.length > 0) t.buildings = [];
          if (t.units.length > 0) t.units = [];
          t.terrain = selectedTerrain;
          t.variation = FM.prng.nextMod(selectedTerrain.variations());
        }
      }
      case EMBuilding:
      tile.terrain = TTPlain;
      tile.variation = 0;
      tile.buildings = [new Building(selectedBuilding, tile, selectedOwner)];
      if (tile.units.length > 0) tile.units = [];
      case EMUnit:
      tile.units = [new Unit(selectedUnit, tile, selectedOwner)];
      if (tile.buildings.length > 0) tile.buildings[0].owner = selectedOwner;
    }
  }
  
  override public function mouseDown(mx:Int, my:Int):Void { mouseHeld = true; brushTick(); }
  override public function mouseUp(mx:Int, my:Int):Void mouseHeld = false;
  override public function mouseMove(mx:Int, my:Int):Void {
    if (!mouseHeld || mode != EMTerrain) return;
    brushTick();
  }
}

enum EditorMode {
  EMTerrain;
  EMBuilding;
  EMUnit;
}
