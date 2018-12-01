package game;

class GSGame extends JamState {
  public static var B_GAME:FluentBitmap;
  
  public static function load(amB:String->Bitmap):Void {
    B_GAME = amB("game").fluent;
  }
  
  public function new(app) {
    super("game", app);
    var ctrl = new GCLocal();
    var player = new Player("P1", Juggernauts, new PCLocal());
    var map = new Map(null);
    map.width = map.height = 15;
    map.tiles = new Vector(map.width * map.height);
    for (i in 0...map.tiles.length) {
      var terrain = (cast FM.prng.nextMod(5):Terrain);
      var variation = FM.prng.nextMod(terrain.variations());
      map.tiles[i] = new Tile(terrain, variation, {x: i % map.width, y: (i / map.width).floor()}, map);
      if (FM.prng.nextMod(5) == 0) map.tiles[i].units.push(new Unit((cast FM.prng.nextMod(4):UnitType), map.tiles[i], player));
    }
    var start:TilePosition = {x: 5, y: 6};
    var neigh = start.neighbours();
    for (n in neigh) {
      var tile = map.get(n);
      tile.terrain = TTVoid;
      tile.variation = 0;
    }
    new Game(map, [player], ctrl);
  }
  
  override public function tick():Void {
    // logic
    Game.I.tick();
    
    // rendering
    ab.fill(Colour.BLACK);
    renderMap(Game.I.map);
  }
  
  var camX:Float = 50;
  var camY:Float = 100;
  
  function renderMap(map:Map):Void {
    var ti = 0;
    var camXI = camX.floor();
    var camYI = camY.floor();
    for (y in 0...map.height) for (rx in 0...map.width) {
      var tile = map.getXY(map.width - rx - 1, y);
      if (tile != null) {
        var screenPos = tile.position.toPixel();
        ab.blitAlphaRect(B_GAME, screenPos.x + camXI, screenPos.y - 6 + camYI, (cast tile.terrain:Int) * 24, tile.variation * 18, 24, 18);
        //for (building in tile.buildings) {
        //  
        //}
        for (unit in tile.units) {
          ab.blitAlphaRect(B_GAME, screenPos.x + camXI - 5, screenPos.y - 14 - tile.height + camYI, 0, 80 + (cast unit.type:Int) * 24, 32, 24);
        }
      }
    }
  }
}
