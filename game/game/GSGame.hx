package game;

class GSGame extends JamState {
  public static var B_GAME:FluentBitmap;
  
  public static function load(amB:String->Bitmap):Void {
    B_GAME = amB("game").fluent;
  }
  
  var mapRenderer:MapRenderer;
  
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
      if (FM.prng.nextMod(5) == 0) map.tiles[i].units.push(new Unit((cast FM.prng.nextMod(5):UnitType), map.tiles[i], player));
      if (FM.prng.nextMod(20) == 0) map.tiles[i].buildings.push(new Building((cast FM.prng.nextMod(2):BuildingType), map.tiles[i], player));
    }
    mapRenderer = new MapRenderer(map);
    new Game(map, [player], ctrl);
  }
  
  override public function tick():Void {
    // logic
    Game.I.tick();
    
    // rendering
    ab.fill(Colour.BLACK);
    mapRenderer.renderMap(ab, app.mouse.x, app.mouse.y);
  }
}
