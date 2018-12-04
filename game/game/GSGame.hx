package game;

class GSGame extends JamState {
  public static var I:GSGame;
  public static var musicOn = true;
  public static var soundOn = true;
  
  public static var B_GAME:FluentBitmap;
  public static var B_PAL:Vector<Colour>;
  public static var B_PLAYER_COLOURS:Vector<Colour>;
  public static var B_PLAYER_COLOURS_DARK:Vector<Colour>;
  public static var B_TERRAIN:Vector<Vector<FluentBitmap>>; // type, variation
  public static var B_BUILDINGS:Vector<Vector<FluentBitmap>>; // type, player
  public static var B_UNITS:Vector<Vector<FluentBitmap>>; // type, player
  public static var B_RANGE_BORDERS:Vector<Vector<Vector<FluentBitmap>>>; // phase, bit, player
  public static var B_ACTIONS:Vector<FluentBitmap>; // action
  public static var B_HP_BAR:Vector<FluentBitmap>; // 0,1 = small, 2,3,4 = full
  public static var B_UI_BOX:FluentBitmap;
  public static var B_UI_BOX_CONFIRM:Vector<FluentBitmap>; // normal, held
  public static var BM_BOX:Box;
  public static var B_CAPTURE:Vector<FluentBitmap>; // capture, raze
  public static var B_STATS:Vector<Vector<FluentBitmap>>; // tab count, active tab
  public static var B_PERK:Vector<FluentBitmap>;
  public static var B_STATS_BUTTON:Vector<FluentBitmap>;
  public static var B_STATS_ICONS:Vector<FluentBitmap>;
  public static var B_ICON:Vector<FluentBitmap>;
  public static var B_UI_ICONS:haxe.ds.Map<String, FluentBitmap>;
  public static var B_END_TURN:Vector<FluentBitmap>;
  public static var B_GAMEOVER:Bitmap;
  
  public static var RANGE_BORDERS_X = [0,  5,  17, 17, 5,  0];
  public static var RANGE_BORDERS_W = [6,  12, 6,  6,  12, 6];
  public static var RANGE_BORDERS_Y = [0,  0,  0,  6,  6,  6];
  
  public static function load(amB:String->Bitmap):Void {
    B_GAME = amB("game").fluent;
    B_PAL = Vector.fromArrayCopy([ for (i in 0...15 * 9) B_GAME.get(64 + (i % 15) * 2, 72 + (i / 15).floor() * 4) ]);
    var grays = Vector.fromArrayCopy(B_PAL.toArray().slice(0, 13));
    B_PLAYER_COLOURS = Vector.fromArrayCopy([B_PAL[11]].concat([ for (i in 0...4) B_PAL[29 + i * 15] ]));
    B_PLAYER_COLOURS_DARK = Vector.fromArrayCopy([B_PAL[5]].concat([ for (i in 0...4) B_PAL[16 + i * 15] ]));
    B_TERRAIN = Vector.fromArrayCopy([ for (i in 0...(cast Terrain.TTNone:Int) + 1)
        Vector.fromArrayCopy([ for (j in 0...(cast i:Terrain).variations())
            B_GAME >> new Cut(i * 24, j * 18, 23, 18)
          ])
      ]);
    function recolour(b:FluentBitmap, player:Int):FluentBitmap {
      if (player != 0) {
        var vec = b.getVector();
        for (i in 0...vec.length) {
          var c = vec[i];
          if (c.isTransparent) continue;
          var closest = Colour.quantise(c, grays);
          vec[i] = B_PAL[15 + (player - 1) * 15 + closest];
        }
        b.setVector(vec);
      }
      return b;
    }
    B_BUILDINGS = Vector.fromArrayCopy([ for (i in 0...(cast BuildingType.BTShrine:Int) + 1)
        Vector.fromArrayCopy([ for (player in 0...5) {
            var b = B_GAME >> new Cut(64, 108, 32, 32);
            b.blitAlpha(recolour(B_GAME >> new Cut(32, 72 + i * 32, 32, 32), player), 0, 0);
            b;
          } ])
      ]);
    B_UNITS = Vector.fromArrayCopy([ for (i in 0...(cast UnitType.Medusa:Int) + 1)
        Vector.fromArrayCopy([ for (player in 0...5)
            recolour(B_GAME >> new Cut(0, 80 + i * 24, 32, 24), player)
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
    B_ACTIONS = Vector.fromArrayCopy([ for (i in 0...4)
        B_GAME >> new Cut(192, i * 16, 24, 16)
      ]);
    B_HP_BAR = Vector.fromArrayCopy([ for (i in 0...2)
        B_GAME >> new Cut(216 + i * 8, 0, 4, 6)
      ].concat([ for (i in 0...3)
        B_GAME >> new Cut(216 + i * 8, 8, 5, 12)
      ]));
    B_UI_BOX = B_GAME >> new Cut(216, 24, 24, 24);
    BM_BOX = new Box(new sk.thenet.geom.Point2DI(8, 8), new sk.thenet.geom.Point2DI(16, 16), 0, 0);
    B_UI_BOX_CONFIRM = Vector.fromArrayCopy([ for (i in 0...3)
        B_GAME >> new Cut(216 + i * 16, 48, 16, 24)
      ].concat([ for (i in 0...5)
        B_GAME >> new Cut(216 + i * 16, 72, 16, 24)
      ]));
    B_CAPTURE = Vector.fromArrayCopy([ for (i in 0...2)
        B_GAME >> new Cut(240, i * 16, 51, 16)
      ]);
    BM_BOX.width = 150;
    BM_BOX.height = 70;
    var statsBase = B_UI_BOX >> BM_BOX;
    B_STATS = Vector.fromArrayCopy([ for (i in 0...3)
        Vector.fromArrayCopy([ for (j in 0...i + 1) {
            var b = statsBase >> new Grow(0, 0, 9, 0);
            for (t in 0...i + 1) {
              b.blitAlpha(
                   B_GAME >> new Cut(216 + (t == 0 ? 0 : 32), 96 + (j == t ? 0 : 24), 30, 20)
                  ,-2 + t * 24
                  ,0
                );
            }
            b;
          } ])
      ]);
    B_PERK = Vector.fromArrayCopy([ for (i in 0...7)
        B_GAME >> new Cut(240 + i * 24, 144, 24, 24)
      ].concat([ for (i in 0...5)
        B_GAME >> new Cut(240 + i * 24, 168, 24, 24)
      ]));
    B_STATS_BUTTON = Vector.fromArrayCopy([ for (i in 0...3)
        B_GAME >> new Cut(216 + i * 24, 192, 24, 24)
      ]);
    B_STATS_ICONS = Vector.fromArrayCopy([ for (i in 0...5)
        B_GAME >> new Cut(216 + i * 24, 216, 24, 24)
      ]);
    B_ICON = Vector.fromArrayCopy([ for (i in 0...2)
        B_GAME >> new Cut(296 + i * 16, 16, 16, 16)
      ]);
    B_UI_ICONS = [
         "sound_on" => B_GAME >> new Cut(240, 32, 16, 16)
        ,"sound_off" => B_GAME >> new Cut(256, 32, 16, 16)
        ,"music_on" => B_GAME >> new Cut(272, 32, 16, 16)
        ,"music_off" => B_GAME >> new Cut(288, 32, 16, 16)
        ,"fullscreen" => B_GAME >> new Cut(304, 32, 16, 16)
        ,"hp" => B_GAME >> new Cut(320, 32, 16, 16)
        ,"arrow_left" => B_GAME >> new Cut(296, 0, 16, 16)
        ,"arrow_right" => B_GAME >> new Cut(312, 0, 16, 16)
        ,"arrow_up" => B_GAME >> new Cut(328, 0, 16, 16)
        ,"arrow_down" => B_GAME >> new Cut(344, 0, 16, 16)
        ,"turn_left" => B_GAME >> new Cut(360, 0, 16, 16)
        ,"turn_right" => B_GAME >> new Cut(376, 0, 16, 16)
        ,"end_turn" => B_GAME >> new Cut(336, 216, 24, 24)
      ];
    B_END_TURN = Vector.fromArrayCopy([ for (i in 0...2)
        B_GAME >> new Cut(296 + i * 16, 16, 16, 16)
      ]);
    B_GAMEOVER = Platform.createBitmap(500, 300, 0);
    var v = B_GAMEOVER.getVector();
    for (i in 0...v.length) v[i] = i % 2 == 0 ? B_PAL[0] : 0;
    B_GAMEOVER.setVector(v);
  }
  
  public static function makeUIBox(to:Bitmap, x:Int, y:Int, w:Int, h:Int):Void {
    if (w <= 0 || h <= 0) return;
    BM_BOX.width = w;
    BM_BOX.height = h;
    to.blit(B_UI_BOX >> BM_BOX, x, y);
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
    mapRenderer.camX -= 3.negposF(ak(KeyA) || ak(ArrowLeft), ak(KeyD) || ak(ArrowRight));
    mapRenderer.camY -= 3.negposF(ak(KeyW) || ak(ArrowUp), ak(KeyS) || ak(ArrowDown));
    
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
        case KeyP: // switch to editor
        st("editor");
        /*
        case KeyP: // import map, switch to editor
        GSEditor.map = Game.I.map;
        st("editor");
        */
        case _:
      }
      true;
    });
  }
}

class RenderTools {
  public static function playerColour(of:Null<Player>):Int {
    return of == null ? 0 : of.colourIndex;
  }
  
  public static function tileBitmap(of:Tile):Bitmap {
    return GSGame.B_TERRAIN[(cast of.terrain:Int)][of.variation];
  }
  
  public static function unitBitmap(of:Unit):Bitmap {
    return GSGame.B_UNITS[(cast of.type:Int)][playerColour(of.owner)];
  }
  
  public static function buildingBitmap(of:Building):Bitmap {
    return GSGame.B_BUILDINGS[(cast of.type:Int)][playerColour(of.owner)];
  }
}
