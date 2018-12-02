package game;

using Lambda;

class GSEditor extends JamState {
  var map:Map;
  var mapRenderer:MapRenderer;
  var selectedTerrain:Terrain = TTPlain;
  var mouseHeld:Bool = false;
  var brush:Int = 0;
  
  function mkTile(x:Int, y:Int):Tile return new Tile(selectedTerrain, FM.prng.nextMod(selectedTerrain.variations()), {x: x, y: y}, map);
  
  public function new(app) {
    super("editor", app);
    map = new Map(null);
    map.width = map.height = 5;
    map.tiles = new Vector(map.width * map.height);
    for (i in 0...map.tiles.length) map.tiles[i] = mkTile(i % map.width, (i / map.width).floor());
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
      case KeyZ: selectedTerrain = TTPlain;
      case KeyX: selectedTerrain = TTDesert;
      case KeyC: selectedTerrain = TTHill;
      case KeyV: selectedTerrain = TTMountain;
      case KeyB: selectedTerrain = TTWater;
      case KeyN: selectedTerrain = TTVoid;
      case KeyI: brush = 0;
      case KeyO: brush = 1;
      case KeyP: brush = 2;
      case _:
    }
  }
  
  override public function tick():Void {
    // controls
    if (!ak(ArrowLeft) && !ak(ArrowRight) && !ak(ArrowUp) && !ak(ArrowDown)) {
      mapRenderer.camX -= 3.negposF(ak(KeyA), ak(KeyD));
      mapRenderer.camY -= 3.negposF(ak(KeyW), ak(KeyS));
    }
    
    // rendering
    ab.fill(Colour.BLACK);
    var mouseTile = mapRenderer.mouseToTile(app.mouse.x, app.mouse.y);
    if (mouseTile == null) mapRenderer.range = [];
    else mapRenderer.range = [ for (t in map.tiles) if (t.position.distance(mouseTile.position) <= brush) t ];
    
    mapRenderer.renderMap(ab, app.mouse.x, app.mouse.y);
    
    // UI
    for (i in 0...6) {
      ab.blitAlphaRect(GSGame.B_GAME, 8 + i * 18, 300 - 20 - ((cast i:Terrain) == selectedTerrain ? 4 : 0), i * 24, 0, 24, 18);
    }
  }
  
  function brushTick():Void {
    var tile = mapRenderer.mouseToTile(app.mouse.x, app.mouse.y);
    if (tile == null) return;
    for (t in map.tiles) {
      if (t.position.distance(tile.position) <= brush) {
        t.terrain = selectedTerrain;
        t.variation = FM.prng.nextMod(selectedTerrain.variations());
      }
    }
  }
  
  override public function mouseDown(mx:Int, my:Int):Void { mouseHeld = true; brushTick(); }
  override public function mouseUp(mx:Int, my:Int):Void mouseHeld = false;
  override public function mouseMove(mx:Int, my:Int):Void {
    if (!mouseHeld) return;
    brushTick();
  }
}
