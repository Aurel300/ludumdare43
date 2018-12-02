package game;

class GSGame extends JamState {
  public static var I:GSGame;
  
  public static var B_GAME:FluentBitmap;
  public static var B_PAL:Vector<Colour>;
  public static var B_PLAYER_COLOURS:Vector<Colour>;
  public static var B_PLAYER_COLOURS_DARK:Vector<Colour>;
  public static var B_TERRAIN:Vector<Vector<FluentBitmap>>; // type, variation
  public static var B_BUILDINGS:Vector<Vector<FluentBitmap>>; // type, player
  public static var B_UNITS:Vector<Vector<FluentBitmap>>; // type, player
  public static var B_RANGE_BORDERS:Vector<Vector<Vector<FluentBitmap>>>; // phase, bit, player
  public static var B_ACTIONS:Vector<Vector<FluentBitmap>>; // action, player
  
  public static var RANGE_BORDERS_X = [0, 5, 0, 17, 5, 17];
  public static var RANGE_BORDERS_W = [6, 12, 6, 6, 12, 6];
  public static var RANGE_BORDERS_Y = [0, 0, 6, 0, 6, 6];
  
  public static function load(amB:String->Bitmap):Void {
    B_GAME = amB("game").fluent;
    B_PAL = Vector.fromArrayCopy([ for (i in 0...15 * 9) B_GAME.get(64 + (i % 15) * 2, 72 + (i / 15).floor() * 4) ]);
    B_PLAYER_COLOURS = Vector.fromArrayCopy([B_PAL[11]].concat([ for (i in 0...4) B_PAL[29 + i * 30] ]));
    B_PLAYER_COLOURS_DARK = Vector.fromArrayCopy([B_PAL[5]].concat([ for (i in 0...4) B_PAL[31 + i * 30] ]));
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
            Vector.fromArrayCopy([ for (c in 0...5)
                B_GAME >> new Cut(168 + RANGE_BORDERS_X[j], i * 16 + RANGE_BORDERS_Y[j], RANGE_BORDERS_W[j], 6)
                  << new ReplaceColour(Colour.WHITE, B_PLAYER_COLOURS[c])
                  << new ReplaceColour(Colour.BLACK, B_PLAYER_COLOURS_DARK[c])
              ])
          ])
      ]);
    B_ACTIONS = Vector.fromArrayCopy([ for (i in 0...3)
        Vector.fromArrayCopy([ for (c in 0...5)
            B_GAME >> new Cut(192, i * 16, 24, 16)
              << new ReplaceColour(Colour.WHITE, B_PLAYER_COLOURS[c])
              << new ReplaceColour(Colour.BLACK, B_PLAYER_COLOURS_DARK[c])
          ])
      ]);
  }
  
  var mapRenderer:MapRenderer;
  var localController:PCLocal;
  var ui:UI;
  
  public function new(app) {
    I = this;
    super("game", app);
    initMap(Map.MAPS["tutorial"]);
  }
  
  public function initMap(mf:haxe.io.Bytes):Void {
    var gameController = new GCLocal();
    var playerController = new PCLocal();
    var players = [
         new Player("P1", Juggernauts, playerController)
        ,new Player("P2", Juggernauts, playerController)
      ];
    var map = new Map(players, mf);
    mapRenderer = new MapRenderer(map);
    ui = new UI(mapRenderer, playerController, gameController);
    new Game(map, players, gameController);
  }
  
  override public function to():Void {
  }
  
  override public function tick():Void {
    // controls
    mapRenderer.camX -= 3.negposF(ak(KeyA), ak(KeyD));
    mapRenderer.camY -= 3.negposF(ak(KeyW), ak(KeyS));
    
    // logic
    ui.tick();
    Game.I.tick();
    
    // rendering
    ab.fill(B_PAL[0]);
    mapRenderer.renderMap(ab, app.mouse.x, app.mouse.y);
    ui.render(ab, app.mouse.x, app.mouse.y);
  }
  
  override public function mouseDown(mx:Int, my:Int):Void ui.mouseDown(mx, my);
  override public function mouseUp(mx:Int, my:Int):Void ui.mouseUp(mx, my);
  override public function mouseMove(mx:Int, my:Int):Void ui.mouseMove(mx, my);
  override public function keyUp(key:Key):Void {
       ui.keyUp(key)
    || ({
      switch (key) {
        case KeyQ: mapRenderer.turnAngle(-1);
        case KeyE: mapRenderer.turnAngle(1);
        case KeyO: // switch to editor
        st("editor");
        case KeyP: // import map, switch to editor
        GSEditor.map = Game.I.map;
        st("editor");
        case _:
      }
      true;
    });
  }
}

class RenderTools {
  public static function playerColour(of:Null<Player>):Colour {
    return of == null ? 0 : of.colourIndex;
  }
}
