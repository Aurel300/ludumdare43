package game;

class GSMenu extends JamState {
  public static var I:GSMenu;
  
  public var introProg = new Bitween(2000, false);
  var menuAction = None;
  var f1:Faction = Juggernauts;
  var f2:Faction = Juggernauts;
  
  public function new(app) {
    I = this;
    super("menu", app);
    //players = [new Player("P1", Juggernauts, null), new Player("P2", Juggernauts, null)];
    //players[0].colourIndex = 1;
    //players[1].colourIndex = 2;
  }
  
  override public function to():Void {
    introProg.setTo(false, true);
    introProg.setTo(true);
    Sfx.startMusic("Intro");
  }
  
  override public function tick():Void {
    introProg.tick();
    introProg.tick();
    introProg.tick();
    introProg.tick();
    Sfx.tick();
    ab.fill(GSGame.B_PAL[(introProg.value >> 2).minI(7)]);
    Text.render(ab, 8, 8, (
      "TBS: TEMPLE-BASED SACRIFICE"
      + "\na game by Aurel B%l& and eidovolta (thenet.sk)"
      + "\n\nSelect your factions, player 1 and player 2:"
      + "\n\n\n\n\n\n\n\n\n\nClick a map name to start:"
      ).substr(0, ((introProg.value >> 2) - 20).maxI(0)));
    
    menuAction = None;
    function button(x:Int, y:Int, t:String, pos:Int, c:Array<Colour>, ma:MenuAction):Void {
      var txt = Text.leftOp(t);
      var hover = false;
      if (introProg.isOn && app.mouse.x.withinI(x, x + 200 - 1) && app.mouse.y.withinI(y, y + 18 - 1)) {
        hover = true;
        menuAction = ma;
      }
      ab.fillRect(x + ((introProg.value - pos) * 3).minI(0), y, 200, 18, c[hover ? 0 : 1]);
      ab.blitAlphaRect(txt, x + (introProg.value - pos).minI(0) + 4, y + 4, 0, 0, txt.width, txt.height);
      if (hover) {
        var txt = (switch (ma) {
          case FactionSelect(_, Juggernauts): "Juggernauts:\nPASSIVE:\n  +1 ATK on siege and charge units.\nACTIVE (15 SACRIFICE POINTS):\n  Siege units no longer have siege.\n  Charge adds twice as much damage.";
          case FactionSelect(_, Harlequins): "Harlequins:\nPASSIVE:\n  All flying units can capture.\nACTIVE (15 SACRIFICE POINTS):\n  All units can capture.\n  Flying units have +1 DEF.";
          case FactionSelect(_, Zephyrs): "Zephyrs:\nPASSIVE:\n  All units have desert and hill affinity.\nACTIVE (15 SACRIFICE POINTS):\n  Ground units have +1 DEF when not\n  in Plains.";
          case FactionSelect(_, Reapers): "Reapers:\nPASSIVE:\n  Monkeys, Bats, Frogs have 4 DEF.\nACTIVE (15 SACRIFICE POINTS):\n  Wolves and Spiders have +1 DEF.";
          case _: return;
        });
        Text.render(ab, 230, 150, txt);
      }
    }
    
    button(8, 65 + 0 * 20, (f1 == Juggernauts ? "> " : "  ") + "Juggernauts", 400 + 0 * 100, [GSGame.B_PLAYER_COLOURS_DARK[1], GSGame.B_PLAYER_COLOURS[1]], FactionSelect(true, Juggernauts));
    button(8, 65 + 1 * 20, (f1 == Harlequins ? "> " : "  ") + "Harlequins" , 400 + 1 * 100, [GSGame.B_PLAYER_COLOURS_DARK[1], GSGame.B_PLAYER_COLOURS[1]], FactionSelect(true, Harlequins) );
    button(8, 65 + 2 * 20, (f1 == Zephyrs ? "> " : "  ") + "Zephyrs"    , 400 + 2 * 100, [GSGame.B_PLAYER_COLOURS_DARK[1], GSGame.B_PLAYER_COLOURS[1]], FactionSelect(true, Zephyrs)    );
    button(8, 65 + 3 * 20, (f1 == Reapers ? "> " : "  ") + "Reapers"    , 400 + 3 * 100, [GSGame.B_PLAYER_COLOURS_DARK[1], GSGame.B_PLAYER_COLOURS[1]], FactionSelect(true, Reapers)    );
    
    button(216, 65 + 0 * 20, (f2 == Juggernauts ? "> " : "  ") + "Juggernauts", 800 + 0 * 100, [GSGame.B_PLAYER_COLOURS_DARK[2], GSGame.B_PLAYER_COLOURS[2]], FactionSelect(false, Juggernauts));
    button(216, 65 + 1 * 20, (f2 == Harlequins ? "> " : "  ") + "Harlequins" , 800 + 1 * 100, [GSGame.B_PLAYER_COLOURS_DARK[2], GSGame.B_PLAYER_COLOURS[2]], FactionSelect(false, Harlequins) );
    button(216, 65 + 2 * 20, (f2 == Zephyrs ? "> " : "  ") + "Zephyrs"    , 800 + 2 * 100, [GSGame.B_PLAYER_COLOURS_DARK[2], GSGame.B_PLAYER_COLOURS[2]], FactionSelect(false, Zephyrs)    );
    button(216, 65 + 3 * 20, (f2 == Reapers ? "> " : "  ") + "Reapers"    , 800 + 3 * 100, [GSGame.B_PLAYER_COLOURS_DARK[2], GSGame.B_PLAYER_COLOURS[2]], FactionSelect(false, Reapers)    );
    
    button(8, 170 + 0 * 20, "Clash of Two Kingdoms", 400 + 0 * 100, [GSGame.B_PLAYER_COLOURS_DARK[3], GSGame.B_PLAYER_COLOURS[3]], MapSelect("clash_of_two_kingdoms"));
    button(8, 170 + 1 * 20, "Marine Madness" , 400 + 1 * 100, [GSGame.B_PLAYER_COLOURS_DARK[3], GSGame.B_PLAYER_COLOURS[3]], MapSelect("marine_madness"));
    button(8, 170 + 2 * 20, "Marine Mountain Madness"    , 400 + 2 * 100, [GSGame.B_PLAYER_COLOURS_DARK[3], GSGame.B_PLAYER_COLOURS[3]], MapSelect("marine_madness_mountains"));
    button(8, 170 + 3 * 20, "Desert Agony"    , 400 + 3 * 100, [GSGame.B_PLAYER_COLOURS_DARK[3], GSGame.B_PLAYER_COLOURS[3]], MapSelect("desert_agony"));
    button(8, 170 + 4 * 20, "Claustrophobia"    , 400 + 3 * 100, [GSGame.B_PLAYER_COLOURS_DARK[3], GSGame.B_PLAYER_COLOURS[3]], MapSelect("claustrophobia"));
    button(8, 170 + 5 * 20, "Distant Lands"    , 400 + 3 * 100, [GSGame.B_PLAYER_COLOURS_DARK[3], GSGame.B_PLAYER_COLOURS[3]], MapSelect("distant_lands"));
  }
  
  override public function keyUp(key:Key):Void {
    switch (key) {
      case KeyM: GSGame.musicOn = !GSGame.musicOn;
      case KeyN: GSGame.soundOn = !GSGame.soundOn;
      case _:
    }
  }
  
  override public function mouseDown(mx:Int, my:Int):Void {}
  override public function mouseUp(mx:Int, my:Int):Void {
    if (!introProg.isOn) {
      introProg.setTo(true, true);
      return;
    }
    switch (menuAction) {
      case FactionSelect(p1, f):
      if (p1) f1 = f;
      else f2 = f;
      case MapSelect(m):
      GSGame.I.initMap(Map.MAPS[m], f1, f2);
      st("game");
      case _: return;
    }
    Sfx.play("select");
  }
}

enum MenuAction {
  None;
  FactionSelect(p1:Bool, f:Faction);
  MapSelect(m:String);
}
