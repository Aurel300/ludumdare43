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
      if (FM.prng.nextMod(5) == 0) map.tiles[i].units.push(new Unit((cast FM.prng.nextMod(5):UnitType), map.tiles[i], player));
      if (FM.prng.nextMod(20) == 0) map.tiles[i].buildings.push(new Building((cast FM.prng.nextMod(2):BuildingType), map.tiles[i], player));
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
  var rangeT:Int = 0;
  
  static var RANGE_BORDERS_X = [0, 5, 0, 17, 5, 17];
  static var RANGE_BORDERS_W = [6, 12, 6, 6, 12, 6];
  static var RANGE_BORDERS_Y = [0, 0, 6, 0, 6, 6];
  
  function renderMap(map:Map):Void {
    var ti = 0;
    var camXI = camX.floor();
    var camYI = camY.floor();
    
    var rangeUnit = null;
    var range = [];
    var rangeBorders = null;
    
    {
      // mouse stuff
      var mX = app.mouse.x - camXI - 11;
      var mY = app.mouse.y - camYI - 6;
      
      var tp = {x: mX, y: mY}.pixelToAxial().axialToCube().cubeRound().cubeToTp();
      var tile = map.get(tp);
      
      if (tile != null && tile.units.length > 0) {
        //range = [tile];
        //rangeBorders = [[ for (i in 0...6) true ]];
        rangeUnit = tile.units[0];
        // Game.I.map.getXY(5, 4).units[0]
      }
      //trace(mX, mY, tp);
    };
    
    if (rangeUnit != null) {
      range = rangeUnit.accessibleTiles;
      rangeT++;
      rangeT %= 3 * 16;
      rangeBorders = range.map(tile -> [ for (n in tile.neighboursAll) n == null || range.indexOf(n) == -1 ]);
    }
    
    for (y in 0...map.height) for (rx in 0...map.width) {
      var tile = map.getXY(map.width - rx - 1, y);
      if (tile != null) {
        var screenPos = tile.position.toPixel();
        if (tile.buildings.length > 0) {
          ab.blitAlphaRect(B_GAME, screenPos.x + camXI - 5, screenPos.y - 20 + camYI, 32, 72 + (cast tile.buildings[0].type:Int) * 32, 32, 32);
        } else {
          ab.blitAlphaRect(B_GAME, screenPos.x + camXI, screenPos.y - 6 + camYI, (cast tile.terrain:Int) * 24, tile.variation * 18, 24, 18);
        }
        var rangeIndex = range.indexOf(tile);
        if (rangeIndex != -1) {
          var borders = rangeBorders[rangeIndex];
          for (rb in 0...6) if (borders[rb]) {
            ab.blitAlphaRect(
               B_GAME
              ,screenPos.x + camXI + RANGE_BORDERS_X[rb]
              ,screenPos.y + camYI + RANGE_BORDERS_Y[rb]
              ,168 + RANGE_BORDERS_X[rb]
              ,((rangeT >> 4) + 1) * 16 + RANGE_BORDERS_Y[rb]
              ,RANGE_BORDERS_W[rb]
              ,6);
          }
        }
        for (unit in tile.units) {
          ab.blitAlphaRect(B_GAME, screenPos.x + camXI - 5, screenPos.y - 14 - tile.height + camYI, 0, 80 + (cast unit.type:Int) * 24, 32, 24);
        }
        if (tile.terrain == TTWater && FM.prng.nextMod(100) == 0)
        tile.variation = FM.prng.nextMod(tile.terrain.variations());
      }
    }
    
    {
      // mouse stuff
      var mX = app.mouse.x - camXI;
      var mY = app.mouse.y - camYI;
      
      var axial = {x: mX, y: mY}.pixelToAxial();
      var screen = axial.axialToPixel();
      var cube = axial.axialToCube().cubeRound();
      var cubeScreen = cube.cubeToAxial().axialToPixel();
      var oddrScreen = cube.cubeToTp().toPixel();
      
      //ab.blitAlphaRect(B_GAME, screen.x.floor() + camXI, screen.y.floor() + camYI, 0, 6, 24, 12);
      //ab.blitAlphaRect(B_GAME, cubeScreen.x.floor() + camXI, cubeScreen.y.floor() + camYI, 0, 6, 24, 12);
      //ab.blitAlphaRect(B_GAME, oddrScreen.x.floor() + camXI, oddrScreen.y.floor() + camYI, 0, 6, 24, 12);
      
      //var tp = {x: mX, y: mY}.pixelToAxial().axialToCube().cubeRound().cubeToTp();
      //var tile = map.get(tp);
    };
  }
}
