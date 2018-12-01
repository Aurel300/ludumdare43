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
      map.tiles[i] = new Tile((cast FM.prng.nextMod(5):Terrain), 0, {x: i % map.width, y: (i / map.width).floor()}, map);
    }
    var start:TilePosition = {x: 5, y: 6};
    var neigh = start.neighbours();
    for (n in neigh) map.get(n).terrain = TTVoid;
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
    for (y in 0...map.height) for (x in 0...map.width) {
      var tile = map.getXY(x, y);
      var screenPos = tile.position.toPixel();
      ab.blitAlphaRect(B_GAME, screenPos.x + camXI, screenPos.y - 12 + camYI, (cast tile.terrain:Int) * 24, 0, 24, 24);
      ti++;
    }
  }
}
