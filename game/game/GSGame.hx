package game;

class GSGame extends JamState {
  public static var B_GAME:FluentBitmap;
  public static var B_PAL:Vector<Colour>;
  public static var B_PLAYER_COLOURS:Vector<Colour>;
  public static var B_TERRAIN:Vector<Vector<FluentBitmap>>; // type, variation
  public static var B_BUILDINGS:Vector<Vector<FluentBitmap>>; // type, player
  public static var B_UNITS:Vector<Vector<FluentBitmap>>; // type, player
  public static var B_RANGE_BORDERS:Vector<Vector<FluentBitmap>>; // phase, bit
  
  public static var RANGE_BORDERS_X = [0, 5, 0, 17, 5, 17];
  public static var RANGE_BORDERS_W = [6, 12, 6, 6, 12, 6];
  public static var RANGE_BORDERS_Y = [0, 0, 6, 0, 6, 6];
  
  public static function load(amB:String->Bitmap):Void {
    B_GAME = amB("game").fluent;
    B_PAL = Vector.fromArrayCopy([ for (i in 0...15 * 9) B_GAME.get(64 + (i % 15) * 2, 72 + (i / 15).floor() * 4) ]);
    B_PLAYER_COLOURS = Vector.fromArrayCopy([B_PAL[11]].concat([ for (i in 0...4) B_PAL[29 + i * 30] ]));
    B_TERRAIN = Vector.fromArrayCopy([ for (i in 0...(cast Terrain.TTVoid:Int) + 1)
        Vector.fromArrayCopy([ for (j in 0...(cast i:Terrain).variations())
            B_GAME >> new Cut(i * 24, j * 18, 23, 18)
          ])
      ]);
    B_BUILDINGS = Vector.fromArrayCopy([ for (i in 0...(cast BuildingType.BTShrine:Int) + 1)
        Vector.fromArrayCopy([ for (c in B_PLAYER_COLOURS) {
            var b = B_GAME >> new Cut(64, 108, 32, 32);
            b.blitAlpha(B_GAME >> new Cut(32, 72 + i * 32, 32, 32) << new GlowBox(c), 0, 0);
            b;
          } ])
      ]);
    B_UNITS = Vector.fromArrayCopy([ for (i in 0...(cast UnitType.Monkey:Int) + 1)
        Vector.fromArrayCopy([ for (c in B_PLAYER_COLOURS)
            B_GAME >> new Cut(0, 80 + i * 24, 32, 24) << new GlowBox(c)
          ])
      ]);
    B_RANGE_BORDERS = Vector.fromArrayCopy([ for (i in 0...4)
        Vector.fromArrayCopy([ for (j in 0...6)
            B_GAME >> new Cut(168 + RANGE_BORDERS_X[j], i * 16 + RANGE_BORDERS_Y[j], RANGE_BORDERS_W[j], 6)
          ])
      ]);
  }
  
  var mapRenderer:MapRenderer;
  
  public function new(app) {
    super("game", app);
    var ctrl = new GCLocal();
    var players = [new Player("P1", Juggernauts, new PCLocal())];
    var map = new Map(players, null);
    map.width = map.height = 15;
    map.tiles = new Vector(map.width * map.height);
    for (i in 0...map.tiles.length) {
      var terrain = (cast FM.prng.nextMod(5):Terrain);
      var variation = FM.prng.nextMod(terrain.variations());
      map.tiles[i] = new Tile(terrain, variation, {x: i % map.width, y: (i / map.width).floor()}, map);
      if (FM.prng.nextMod(5) == 0) map.tiles[i].units.push(new Unit((cast FM.prng.nextMod(5):UnitType), map.tiles[i], players[0]));
      if (FM.prng.nextMod(5) == 0) map.tiles[i].buildings.push(new Building((cast FM.prng.nextMod(5):BuildingType), map.tiles[i], null));
    }
    mapRenderer = new MapRenderer(map);
    new Game(map, players, ctrl);
  }
  
  override public function tick():Void {
    // logic
    Game.I.tick();
    
    // rendering
    ab.fill(Colour.BLACK);
    mapRenderer.renderMap(ab, app.mouse.x, app.mouse.y);
  }
}

class RenderTools {
  public static function playerColour(of:Null<Player>):Colour {
    return of == null ? 0 : of.colourIndex;
  }
}
