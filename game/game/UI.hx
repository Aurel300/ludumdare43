package game;

class UI {
  static final MOVE_TIME = 20;
  static final ATTACK_TIME = 15;
  static final REPAIR_TIME = 30;
  static final CAPTURE_TIME = 60;
  
  static var TOOLTIP:Array<TooltipProto> = [
       {has: u -> u.stats.affinity.indexOf(Terrain.TTHill) != -1, name: '${Text.t(RegularGreen)}Mountain/Hill affinity', t: "No slowdown on mountains or hills."}
      ,{has: u -> u.stats.affinity.indexOf(Terrain.TTDesert) != -1, name: '${Text.t(RegularGreen)}Desert affinity', t: "No slowdown in desert."}
      ,{has: u -> u.stats.repair, name: '${Text.t(RegularGreen)}Repair', t: "Can repair friendly units, restoring 2HP per turn."}
      ,{has: u -> u.stats.camouflage, name: '${Text.t(RegularGreen)}Camouflage', t: "STL increased by remaining MOV at the end of turn."}
      ,{name: '${Text.t(RegularGreen)}Shrine', t: "Provides 3 cycles every turn."}
      ,{name: '${Text.t(RegularGreen)}Forge', t: "Increases production tier by 1."}
      ,{name: '${Text.t(RegularGreen)}Fortress', t: "Adds +1 ATK, +1 DEF, and +1 VIS to any friendly unit on this tile."}
      ,{has: u -> u.stats.charge, name: '${Text.t(RegularRed)}Charge', t: "ATK increased by 1 for each hex tile away from start."}
      ,{has: u -> u.stats.siege, name: '${Text.t(RegularRed)}Siege', t: "Can only attack when MOV is full. Cannot counter- strike."}
      ,{has: u -> u.stats.healthATK, name: '${Text.t(RegularRed)}Health attack', t: "ATK increased by current HP."}
      ,{has: u -> u.stats.kamikaze, name: '${Text.t(RegularRed)}Kamikaze', t: "Attacking destroys self."}
      ,{has: u -> u.stats.medusaGaze, name: '${Text.t(RegularRed)}Medusa gaze', t: "Any attacked unit instantly turns neutral."}
      ,{name: '${Text.t(RegularGreen)}Build ground units', t: "(Click to show menu)"}
      ,{name: '${Text.t(RegularGreen)}Build water units', t: "(Click to show menu)"}
      ,{name: '${Text.t(RegularGreen)}Build flying units', t: "(Click to show menu)"}
      ,{name: '${Text.t(RegularRed)}Surrender battle', t: "(Click to give up)"}
      ,{name: '${Text.t(RegularRed)}Sacrifice', t: "(Click to show menu)"}
    ];
  
  static var TOOLTIP_BUILD:haxe.ds.Map<UnitType, TooltipProto> = [ for (k in common.UnitType.UnitTypeTools.TYPE_STATS.keys())
      k => {name: 'Build ${Text.t(RegularYellow)}${common.UnitType.UnitTypeTools.name(k)}${Text.t(SmallYellow)} (TIER ${common.UnitType.UnitTypeTools.TYPE_STATS[k].tier})'}
    ];
  
  public static function load():Void {
    for (t in TOOLTIP) {
      var b = Platform.createBitmap(150, 70 + 48, 0);
      Text.render(b, 4, 44, t.name);
      if (t.t != null) b.blitAlpha(Text.justify(t.t, 150 - 8, Regular, 12), 4, 44 + 16);
      t.bg = b;
    }
    for (k in TOOLTIP_BUILD.keys()) {
      var t = TOOLTIP_BUILD[k];
      var b = Platform.createBitmap(150, 70 + 48, 0);
      Text.render(b, 4, 44, t.name);
      var stats = common.UnitType.UnitTypeTools.stats(k, null);
      t.t = 
      '${Text.t(Small)} HP: ${Text.t(Regular)}${stats.maxHP}${Text.t(Small)}'
      + '  ${Text.t(Small)}MOV: ${Text.t(Regular)}${stats.maxMP}${Text.t(Small)}'
      + '  ${Text.t(Small)}ATK: ${Text.t(Regular)}${stats.ATK}${Text.t(Small)}'
      + '\n${Text.t(Small)}RNG: ${Text.t(Regular)}${stats.RNG}${Text.t(Small)}'
      + '  ${Text.t(Small)}DEF: ${Text.t(Regular)}${stats.DEF}${Text.t(Small)}'
      + '  ${Text.t(Small)}CYC: ${Text.t(Regular)}${stats.CYC}${Text.t(Small)}'
      ;
      Text.render(b, 4, 44 + 16, t.t);
      t.bg = b;
    }
  }
  
  var buttons:Array<{x:Int, y:Int, ?big:Bool, icon:String, down:Bool, click:Void->Void, ?hold:Void->Void, tt:String}>;
  
  public var mapRenderer:MapRenderer;
  public var localController:PCLocal;
  public var gameController:GameController;
  
  public var selection:UISelection = None;
  public var modal = {
       show: new Bitween(20, false)
      ,x: -1
      ,y: -1
      ,w: 0
      ,h: 0
      ,confirmX: 4
      ,confirmY: 3
      ,confirmW: 16
      ,confirmH: 24
      ,confirmHeld: false
      ,target: ModalTarget.MTPosition(0, 0)
      ,targetW: 0
      ,targetH: 0
      ,confirmAction: null
      ,cancelAction: UISelection.None
      ,highlightTimer: 0
      ,bg: (null:Bitmap)
    };
  public var mouseAction:UIAction = None;
  public var stats = {
       show: new Bitween(30, false)
      ,y: 300
      ,gfx: (null:Bitmap)
      ,bg: (null:Bitmap)
      ,text: (null:Bitmap)
      ,tooltips: ([]:Array<Tooltip>)
    };
  public var mTooltip = {
       show: new Bitween(10, false)
      ,y: 300
      ,text: ""
      ,lastText: ""
      ,bg: (null:Bitmap)
    };
  public var mGameOver = {
       show: new Bitween(100, false)
      ,winner: (null:Player)
    };
  
  public var handlingUpdate:Null<GameUpdate> = null;
  public var handlingTimer:Int = 0;
  
  public function new(mapRenderer:MapRenderer, localController:PCLocal, gameController:GameController) {
    stats.bg = Platform.createBitmap(150, 70 + 48, 0);
    stats.text = Platform.createBitmap(150, 70 + 48, 0);
    this.mapRenderer = mapRenderer;
    this.localController = localController;
    this.gameController = gameController;
    localController.updateObservers.push(tick);
    
    buttons = [
       {down: false, x: 500 - 16, y: 0, icon: "music", click: () -> GSGame.musicOn = !GSGame.musicOn, tt: "Toggle music"}
      ,{down: false, x: 500 - 16, y: 16, icon: "sound", click: () -> GSGame.soundOn = !GSGame.soundOn, tt: "Toggle sound"}
      ,{down: false, x: 500 - 16, y: 32, icon: "fullscreen", click: () -> {}, tt: "Toggle fullscreen"}
      ,{down: false, x: 150, y: 300 - 16, icon: "hp", click: () -> mapRenderer.hpBarShow.toggle(), tt: "Toggle HP bars"}
      ,{down: false, x: 166, y: 300 - 16, icon: "arrow_left", click: () -> {}, hold: () -> mapRenderer.camX += 3, tt: "Move camera to the left"}
      ,{down: false, x: 198, y: 300 - 16, icon: "arrow_right", click: () -> {}, hold: () -> mapRenderer.camX -= 3, tt: "Move camera to the right"}
      ,{down: false, x: 182, y: 300 - 32, icon: "arrow_up", click: () -> {}, hold: () -> mapRenderer.camY += 3, tt: "Move camera up"}
      ,{down: false, x: 182, y: 300 - 16, icon: "arrow_down", click: () -> {}, hold: () -> mapRenderer.camY -= 3, tt: "Move camera down"}
      ,{down: false, x: 166, y: 300 - 32, icon: "turn_left", click: () -> mapRenderer.turnAngle(-1), tt: "Turn camera to the left"}
      ,{down: false, x: 198, y: 300 - 32, icon: "turn_right", click: () -> mapRenderer.turnAngle(1), tt: "Turn camera to the right"}
      ,{down: false, x: 500 - 24, y: 300 - 24, big: true, icon: "end_turn", click: () -> {
          localController.queuedActions.push(EndTurn);
          clearUI();
        }, tt: "End turn"}
    ];
  }
  
  public function clearUI():Void {
    modal.show.setTo(false);
    deselect();
  }
  
  public function tick():Void {
    mapRenderer.activePlayer = localController.activePlayer;
    
    // logic
    function mkOff(from:TilePosition, to:TilePosition):TilePosition {
      var fromPixel = from.toPixel(mapRenderer.camAngle);
      var toPixel = to.toPixel(mapRenderer.camAngle);
      return {x: toPixel.x - fromPixel.x, y: toPixel.y - fromPixel.y};
    }
    function applyOff(unit:Unit, off:TilePosition, from:TilePosition, prog:Float):Void {
      unit.offX = off.x * prog;
      unit.offY = off.y * prog;
      if (unit.offY > 0) unit.displayTile = Game.I.map.get(from);
    }
    function done() { handlingUpdate = gameController.pollUpdate(Game.I); handlingTimer = 0; updateRange(); }
    if (handlingUpdate == null) done();
    while (handlingUpdate != null) switch (handlingUpdate) {
      case MoveUnit(u, from, to, _) if (handlingTimer < MOVE_TIME):
      applyOff(u, mkOff(from, to), from, -1 + Timing.quartInOut.getF(handlingTimer / MOVE_TIME));
      u.actionRelevant = true;
      handlingTimer++; break;
      case AttackUnit(au, du, dmg, attack) if (handlingTimer < ATTACK_TIME):
      if (handlingTimer == 0) {
        Sfx.play('hit_${au.name.toLowerCase()}');
      }
      du.hurtTimer = dmg * 8;
      au.actionRelevant = true;
      du.actionRelevant = true;
      if (au.tile.position.distance(du.tile.position) <= 1) {
        applyOff(au, mkOff(au.tile.position, du.tile.position), au.tile.position, .5 * Timing.quartIn.getF(handlingTimer / ATTACK_TIME));
      } else {
        au.offY = -3 * Timing.quartOut.getF(handlingTimer / ATTACK_TIME);
      }
      handlingTimer++; break;
      case RepairUnit(u, target, rep) if (handlingTimer < REPAIR_TIME):
      u.actionRelevant = true;
      target.actionRelevant = true;
      applyOff(u, mkOff(u.tile.position, target.tile.position), u.tile.position, .7 * Timing.sineInOut.getF(handlingTimer / REPAIR_TIME));
      handlingTimer++; break;
      case CapturingBuilding(u, b, capture, progress) if (handlingTimer < CAPTURE_TIME):
      if (handlingTimer == 0) {
        mapRenderer.captureBar.show.setTo(true);
        mapRenderer.captureBar.target = b;
        mapRenderer.captureBar.prevNum = b.captureCost - (progress - 1);
        mapRenderer.captureBar.nextNum = b.captureCost - progress;
        mapRenderer.captureBar.cycleProg = 1;
        mapRenderer.captureBar.capture = capture;
      }
      handlingTimer++; break;
      case CaptureBuilding(u, b, capture) if (handlingTimer < CAPTURE_TIME):
      if (handlingTimer == 0) {
        mapRenderer.captureBar.show.setTo(true);
        mapRenderer.captureBar.target = b;
        mapRenderer.captureBar.prevNum = 1;
        mapRenderer.captureBar.nextNum = 0;
        mapRenderer.captureBar.cycleProg = 1;
        mapRenderer.captureBar.capture = capture;
      }
      handlingTimer++; break;
      case CapturingBuilding(_, _, _, _) | CaptureBuilding(_, _, _):
      deselect();
      mapRenderer.captureBar.show.setTo(false); done();
      case RepairUnit(u, du, _) | AttackUnit(u, du, _, _):
      selectTile(u.tile);
      u.offX = u.offY = 0; u.displayTile = null; u.actionRelevant = false; du.actionRelevant = false; done();
      case MoveUnit(u, _, _, _):
      selectTile(u.tile);
      u.offX = u.offY = 0; u.displayTile = null; u.actionRelevant = false; done();
      case RemoveUnit(u): deselect(); done();
      case TurnUnit(_) | BuildUnit(_, _, _) | CaptureUnit(_): done();
      case GameOver(w):
      mGameOver.show.setTo(true);
      mGameOver.winner = w;
      selection = GameOver;
      done();
    }
    
    // modal
    modal.show.tick();
    var tp:TilePosition = (switch (modal.target) {
        case MTPosition(x, y): {x: x, y: y};
        case MTTile(tile):
        var pos = tile.position.toPixel(mapRenderer.camAngle);
        pos.x += mapRenderer.camXI + 16;
        pos.y += mapRenderer.camYI + 24;
        pos;
        case MTCenter: {x: 250, y: 150};
      });
    modal.w = (modal.targetW * Timing.quartInOut(modal.show.valueF)).round();
    modal.h = (modal.targetH * Timing.quartOut(modal.show.valueF)).round();
    modal.x = (tp.x - (modal.w >> 2)).clampI(0, 500 - modal.w);
    modal.y = (tp.y).clampI(0, 300 - modal.h);
    
    mTooltip.show.tick();
    mGameOver.show.tick();
    stats.show.tick();
    
    for (b in buttons) if (b.down && b.hold != null) b.hold();
  }
  
  public function render(to:Bitmap, mx:Int, my:Int):Void {
    // stats
    if (!stats.show.isOff) {
      stats.y = 300 - Timing.quartInOut.getI(stats.show.valueF, stats.gfx.height);
      to.blitAlpha(stats.gfx, 0, stats.y);
      to.blitAlpha(stats.bg, 0, stats.y - 32);
      switch (mouseAction) {
        case StatsTooltip(tt): to.blitAlpha(tt.tt.bg, 0, stats.y - 32);
        case _: to.blitAlpha(stats.text, 0, stats.y - 32);
      }
    }
    
    // buttons
    for (b in buttons) {
      var f = b.down ? 1 : 0;
      to.blitAlpha(b.big != null ? GSGame.B_STATS_BUTTON[f] : GSGame.B_ICON[f], b.x, b.y);
      to.blitAlpha(GSGame.B_UI_ICONS[switch (b.icon) {
          case "music": GSGame.musicOn ? "music_on" : "music_off";
          case "sound": GSGame.soundOn ? "sound_on" : "sound_off";
          case _: b.icon;
        }], b.x, b.y);
    }
    
    // show modal
    if (!modal.show.isOff) {
      GSGame.makeUIBox(to, modal.x, modal.y, modal.w, modal.h);
      var confirmFrame = GSGame.B_UI_BOX_CONFIRM[modal.confirmAction != null ? (modal.confirmHeld ? 1: 0) : 2];
      if (!modal.show.isOn) {
        to.blitAlphaRect(
             confirmFrame
            ,modal.x + modal.confirmX
            ,modal.y + modal.confirmY
            ,0
            ,0
            ,16.minI(modal.w - modal.confirmX)
            ,24.minI(modal.h - modal.confirmY)
          );
        to.blitAlphaRect(
             modal.bg
            ,modal.x + 4 + 16 + 4
            ,modal.y + 6
            ,0
            ,0
            ,modal.bg.width.minI(modal.w - 4 - 16 - 4)
            ,modal.bg.height.minI(modal.h - 4)
          );
      } else {
        to.blitAlpha(
             confirmFrame
            ,modal.x + modal.confirmX
            ,modal.y + modal.confirmY
          );
        if (modal.confirmAction != null && modal.highlightTimer < 5 * 4) {
          to.blitAlpha(
               GSGame.B_UI_BOX_CONFIRM[3 + (modal.highlightTimer >> 2)]
              ,modal.x + modal.confirmX
              ,modal.y + modal.confirmY
            );
        }
        to.blitAlpha(
             modal.bg
            ,modal.x + 4 + 16 + 4
            ,modal.y + 6
          );
        modal.highlightTimer++;
        modal.highlightTimer %= 240;
      }
    }
    
    // top status bar
    if (localController.activePlayer != null) {
      Text.render(to, 4, 4,
        '${Text.tp(localController.activePlayer)}${localController.activePlayer.name}${Text.t(Small)}\'s turn');
      Text.render(to, 178, 4, 'Time left in turn: ${Std.int(Game.I.turnTimer / 60)}');
      Text.render(to, 4, 14, '${Text.t(Small)}CYC: ${localController.activePlayer.cycles} (+${localController.activePlayer.lastCycleGain})');
    }
    
    // main tooltip
    if (!mTooltip.show.isOff && selection != GameOver) {
      mTooltip.y = 300 - Timing.quartInOut.getI(mTooltip.show.valueF, 16);
      to.blitAlpha(mTooltip.bg, 500 - 24 - mTooltip.bg.width, mTooltip.y);
    }
    
    // game over text
    if (!mGameOver.show.isOff) {
      var gy = 300 - Timing.quartInOut.getI(mGameOver.show.valueF, 150);
      to.blitAlpha(GSGame.B_GAMEOVER, 0, 300 - Timing.quartInOut.getI(mGameOver.show.valueF, 300));
      to.fillRect(0, gy, 500, 40, GSGame.B_PLAYER_COLOURS[mGameOver.winner.playerColour()]);
      Text.render(to, 250, gy + 10, 'GAME OVER\n' + (mGameOver.winner == null ? "NO WINNER!" : '${mGameOver.winner.name} WINS!'));
    }
  }
  
  function deselect():Void {
    if (selection == None) return;
    selection = None;
    updateRange();
  }
  
  function showModal(
     confirm:Void->Void
    ,cancel:UISelection
    ,target:ModalTarget
    ,text:String
    ,?w:Int
  ):Void {
    modal.show.setTo(true);
    modal.confirmAction = confirm;
    modal.cancelAction = cancel;
    modal.target = target;
    modal.targetW = w == null ? 140 : w;
    (modal.bg:Bitmap);
    modal.bg = Text.left(text, modal.targetW - 8 - 16 - 4);
    modal.targetH = (modal.bg.height + 10).maxI(16 + modal.confirmH);
    modal.highlightTimer = 0;
  }
  
  function updateRange():Void {
    if (localController.activePlayer == null) return;
    mapRenderer.rangeColour = localController.activePlayer.colourIndex;
    mapRenderer.actions = [];
    stats.show.setTo(false);
    switch (selection) {
      case BuildGround(b, cancel) | BuildWater(b, cancel) | BuildFlying(b, cancel):
      stats.show.setTo(true);
      stats.gfx = GSGame.B_STATS[0][0];
      stats.bg.fill(0);
      stats.text.fill(0);
      stats.tooltips = [];
      var cx = stats.bg.width - 4 - 24;
      var cy = stats.bg.height - 4 - 24 - 7;
      for (u in (switch (selection) {
          case BuildGround(b, cancel): [
             UnitType.Hog
            ,UnitType.Bull
            ,UnitType.Chamois
            ,UnitType.BombardierAnt
            ,UnitType.Spider
            ,UnitType.Monkey
            ,UnitType.Wolf
          ];
          case BuildWater(b, cancel): [
             UnitType.Medusa
            ,UnitType.Swordfish
            ,UnitType.Snake
            ,UnitType.Squid
            ,UnitType.Octopus
            ,UnitType.Frog
          ];
          case BuildFlying(b, cancel): [
             UnitType.Eagle
            ,UnitType.Mosquito
            ,UnitType.Bumblebee
            ,UnitType.Bat
          ];
          case _: throw "?";
        })) {
        stats.bg.blitAlpha(GSGame.B_UNITS[(cast u:Int)][localController.activePlayer.colourIndex], cx - 4, cy);
        stats.tooltips.push({
             x: cx
            ,y: cy
            ,w: 19
            ,h: 24
            ,click: () -> {
              var build = b.summariseBuild(u);
              var text =
              'Build ${Text.tp(localController.activePlayer)}${common.UnitType.UnitTypeTools.name(u)}${Text.t(Regular)}'
              + (!build.suffCost ? '\n${Text.t(SmallRed)}(INSUFFICIENT CYCLES)' : '\n${Text.t(SmallYellow)}(COST: ${build.cost} CYCLES)')
              + (!build.suffTier ? '\n${Text.t(SmallRed)}(INSUFFICIENT TIER)' : '')
              + (!build.space ? '\n${Text.t(SmallRed)}(NO SPACE FOR UNIT)' : '')
              ;
              showModal(
                build.canBuild ? () -> {
                    localController.queuedActions.push(Build(u, b));
                    deselect();
                  } : null
                ,selection
                ,MTTile(b.tile)
                ,text
              );
            }
            ,tt: TOOLTIP_BUILD[u]
          });
        cx -= 19;
      }
      
      case STileBase(t, ts, i):
      stats.gfx = GSGame.B_STATS[ts.length - 1][i];
      stats.bg.fill(0);
      stats.text.fill(0);
      for (j in 0...ts.length) {
        switch (ts[j]) {
          case STile(t): stats.bg.blitAlphaRect(t.tileBitmap(), j * 24, 26 + (j == i ? 1 : 3), 0, 0, 24, j == i ? 18 : 12);
          case SUnit(u): stats.bg.blitAlphaRect(u.unitBitmap(), j * 24 - 4, 18 + (j == i ? 1 : 3), 0, 0, 32, j == i ? 24 : 20);
          case SBuilding(b): stats.bg.blitAlphaRect(b.buildingBitmap(), j * 24 - 4, 10 + (j == i ? 1 : 3), 0, 0, 32, j == i ? 32 : 28);
          case _:
        }
      }
      stats.show.setTo(true);
      stats.tooltips = [];
      mapRenderer.range = [t];
      var text = (switch (ts[i]) {
        case STile(_):
        Text.render(stats.text, stats.bg.width - 30, 44, "(TILE)", SmallYellow);
        function showInfInt(t:InfInt):String return (switch (t) {
            case Num(n): '$n';
            case Inf: "N/A";
          });
        '${t.name}'
        + '\n${Text.t(Small)}MOV cost:'
        + '\n${Text.t(Small)}  ${Text.t(Regular)}${showInfInt(t.terrain.tdfG())} (ground)'
        + '\n${Text.t(Small)}  ${Text.t(Regular)}${showInfInt(t.terrain.tdfF())} (flying)'
        + '\n${Text.t(Small)}  ${Text.t(Regular)}${showInfInt(t.terrain.tdfS())} (swimming)';
        case SUnit(u):
        Text.render(stats.text, stats.bg.width - 30, 44, "(UNIT)", SmallYellow);
        if (u.owner == localController.activePlayer) {
          mapRenderer.range = u.accessibleTiles;
          mapRenderer.actions = u.accessibleActions;
        }
        var cx = stats.bg.width - 4 - 24;
        var cy = stats.bg.height - 4 - 24 - 7;
        for (tti in 0...TOOLTIP.length) {
          var t = TOOLTIP[tti];
          if (t.has == null || !t.has(u)) continue;
          stats.bg.blitAlpha(GSGame.B_PERK[tti], cx, cy);
          stats.tooltips.push({
               x: cx
              ,y: cy
              ,w: 24
              ,h: 24
              ,tt: t
            });
          cx -= 24;
        }
        // TODO: misnamed functions (baseXY)
        function showMod(cur:Int, stat:Int):String {
          return '${Text.t(Regular)}${cur}${Text.t(Small)}'
            + (stat == cur
              ? ""
              : ' ${Text.t(SmallYellow)}(${stat}${cur > stat ? "+" : "-"}${(cur - stat).absI()})');
        }
        '${Text.tp(u.owner)}${u.name} ${Text.t(Small)}(${Text.tp(u.owner, false)}${u.owner == null ? "NEUTRAL" : u.owner.name}${Text.t(Small)})${Text.t(Regular)}'
        + '\n${Text.t(Small)} HP: ${Text.t(Regular)}${u.stats.HP}${Text.t(Small)}/${u.stats.maxHP}'
        + '\n${Text.t(Small)}MOV: ${Text.t(Regular)}${u.stats.MP}${Text.t(Small)}/${u.stats.maxMP}'
        + '\n${Text.t(Small)}ATK: ${showMod(u.baseAttack(), u.stats.ATK)}'
        + '\n${Text.t(Small)}RNG: ${Text.t(Regular)}${u.stats.RNG}${Text.t(Small)}'
        + '\n${Text.t(Small)}DEF: ${showMod(u.baseDefense(), u.stats.DEF)}'
        ;
        case SBuilding(b):
        var cx = stats.bg.width - 4 - 24;
        var cy = stats.bg.height - 4 - 24 - 7;
        function emitPerk(tti:Int):Void {
          var t = TOOLTIP[tti];
          stats.bg.blitAlpha(GSGame.B_PERK[tti], cx, cy);
          stats.tooltips.push({
               x: cx
              ,y: cy
              ,w: 24
              ,h: 24
              ,tt: t
            });
          cx -= 24;
        }
        function emitButton(tti:Int, icon:Int, click:Void->Void):Void {
          if (b.owner != localController.activePlayer) return;
          var t = TOOLTIP[tti];
          stats.bg.blitAlpha(GSGame.B_STATS_BUTTON[0], cx, cy);
          stats.bg.blitAlpha(GSGame.B_STATS_ICONS[icon], cx, cy);
          stats.tooltips.push({
               x: cx
              ,y: cy
              ,w: 24
              ,h: 24
              ,tt: t
              ,click: click
            });
          cx -= 24;
        }
        switch (b.type) {
          case BTTempleTron | BTFactoreon:
          if (b.type == BTTempleTron) {
            emitPerk(4);
            emitButton(15, 3, () -> selection = Surrender(selection));
            emitButton(16, 4, () -> selection = Sacrifice(b, selection));
          }
          emitButton(12, 0, () -> selection = BuildGround(b, selection));
          case BTDock: emitButton(13, 1, () -> selection = BuildWater(b, selection));
          case BTEyrie: emitButton(14, 2, () -> selection = BuildFlying(b, selection));
          case BTForge: emitPerk(5);
          case BTFortress: emitPerk(6);
          case BTShrine: emitPerk(4);
        }
        Text.render(stats.text, stats.bg.width - 46, 44, "(BUILDING)", SmallYellow);
        '${Text.tp(b.owner)}${b.name} ${Text.t(Small)}(${Text.tp(b.owner, false)}${b.owner == null ? "NEUTRAL" : b.owner.name}${Text.t(Small)})${Text.t(Regular)}'
        ;
        case _: "";
      });
      Text.render(stats.text, 4, 44, text);
      case None: mapRenderer.range = [];
      case _:
    }
  }
  
  function selectTile(sel:Tile):Void {
    // update selection
    function freshTile() {
      return STileBase(sel, sel.units.map(SUnit).concat(sel.buildings.length > 0 ? sel.buildings.map(SBuilding) : [STile(sel)]), 0);
    }
    selection = (switch (selection) {
        case STileBase(prev, ts, i):
        if (prev == sel) {
          // cycle through selection on the tile
          STileBase(prev, ts, (i + 1) % ts.length);
        } else {
          deselect();
          freshTile();
        }
        case _:
        deselect();
        freshTile();
      });
    updateRange();
  }
  
  public function mouseDown(mx:Int, my:Int):Bool {
    if (handlingUpdate != null) return true;
    switch (mouseAction) {
      case ConfirmModal: modal.confirmHeld = true;
      case Button(i): buttons[i].down = true;
      case _: return false;
    }
    return true;
  }
  
  public function mouseUp(mx:Int, my:Int):Bool {
    mouseMove(mx, my);
    modal.confirmHeld = false;
    
    if (selection == GameOver) {
      if (mGameOver.show.isOn) {
        Main.I.st("editor");
      }
      return true;
    }
    
    if (handlingUpdate != null) return true;
    function handleUnitOrder(unit:Unit, target:Tile):Bool {
      var accessible = unit.accessibleTiles;
      var actions = unit.accessibleActions;
      if (unit.stats.acted) return false;
      if (unit.owner != localController.activePlayer) return false;
      for (action in actions) if (switch (action) {
          case Attack(u) | Repair(u) | AttackNoDamage(u) | CaptureUnit(u): u.tile == target;
          case Capture(b): b.tile == target;
        }) {
          var confirmAction = () -> localController.queuedActions.push(UnitAction(unit, action));
          var text = (switch (action) {
              case Attack(u):
              var attack = unit.summariseAttack(u);
              'Attack ${Text.tp(u.owner)}${u.name}${Text.t(Regular)}'
              + (attack.willStrike
                ? '\n${Text.t(SmallYellow)}STRIKE'
                  + '\n${Text.t(Regular)} DMG: ${attack.dmgA}'
                  + (attack.killD ? ' ${Text.t(SmallRed)}LETHAL' : "")
                  + (attack.willTurn ? ' ${Text.t(SmallRed)}WILL TURN' : "")
                : '')
              + (attack.willCounter
                ? '\n${Text.t(SmallYellow)}COUNTER-STRIKE'
                  + '\n${Text.t(Regular)} DMG: ${attack.dmgD}' + (attack.killA ? ' ${Text.t(SmallRed)}LETHAL' : "")
                : '\n${Text.t(SmallYellow)}NO COUNTER-STRIKE'
                  + (attack.killD ? '\n${Text.t(Regular)} ${Text.t(SmallYellow)}(Unit destroyed)' : "")
                  + (attack.willSuicide ? '\n${Text.t(Regular)} ${Text.t(SmallRed)}KAMIKAZE ATTACK' : "")
                );
              case AttackNoDamage(u):
              confirmAction = null;
              'Attack ${Text.tp(u.owner)}${u.name}${Text.t(Regular)}'
              + '\n${Text.t(SmallYellow)}STRIKE'
              + '\n${Text.t(Regular)} DMG: ${Text.t(SmallRed)}0';
              case Repair(u):
              var repair = unit.summariseRepair(u);
              'Repair ${u.name}'
              + '\n HP: +${repair.rep}' + (repair.full ? ' ${Text.t(SmallGreen)}FULL' : "");
              case Capture(b):
              var capture = unit.summariseCapture(b);
              (capture.capture ? "Capture" : "Raze")
              + ' ${Text.tp(b.owner)}${b.name}${Text.t(Regular)}'
              + '\n ${Text.t(SmallYellow)}' + (capture.start ? "(START)" : "(CONTINUE)")
              + '\n${Text.t(Regular)} Turns left: ${capture.turnsLeft}';
              case CaptureUnit(target):
              'Capture ${Text.tp(target.owner)}${target.name}${Text.t(Regular)}';
            });
          showModal(
               confirmAction
              ,selection
              ,MTTile(unit.tile)
              ,text
            );
          return true;
        }
      if (target != unit.tile
        && accessible.indexOf(target) != -1) {
        localController.queuedActions.push(MoveUnit(unit, target));
        return true;
      }
      return false;
    }
    switch [selection, mouseAction] {
      case [_, ConfirmModal]: modal.show.setTo(false); if (modal.confirmAction != null) modal.confirmAction();
      case [_, CancelModal]: modal.show.setTo(false); selection = modal.cancelAction;
      case [_, Button(i)]:
      if (buttons[i].down) buttons[i].click();
      for (b in buttons) b.down = false;
      case [STileBase(_, ts, i), SelectTile(target)]: switch (ts[i]) {
        case SUnit(u): if (!handleUnitOrder(u, target)) selectTile(target);
        case _: selectTile(target);
      }
      case [_, SelectTile(t)]: selectTile(t);
      case [_, Stats]: return true;
      case [_, StatsTooltip(tt)]:
      if (tt.click != null) tt.click();
      return true;
      case [_, None]: return false;
    }
    return true;
  }
  
  public function mouseMove(mx:Int, my:Int):Bool {
    if (selection == GameOver) {
      mTooltip.show.setTo(false);
      return false;
    }
    
    function r() {
      mTooltip.text = (switch (mouseAction) {
          case Button(i): buttons[i].tt;
          case _: "";
        });
      if (mTooltip.lastText != mTooltip.text) {
        if (mTooltip.text != "") mTooltip.bg = Text.leftOp(mTooltip.text);
        mTooltip.lastText = mTooltip.text;
      }
      mTooltip.show.setTo(mTooltip.text != "");
    }
    
    if (handlingUpdate != null) {
      // CURSOR: hourglass
      r(); return true;
    }
    mouseAction = None;
    
    // modal
    if (!modal.show.isOff) {
      if (mx.withinI(modal.x + modal.confirmX, modal.x + modal.confirmX + modal.confirmW - 1)
          && my.withinI(modal.y + modal.confirmY, modal.y + modal.confirmY + modal.confirmH - 1)) {
        mouseAction = ConfirmModal;
      } else {
        mouseAction = CancelModal;
      }
      r(); return true;
    }
    
    // buttons
    for (i in 0...buttons.length) {
      var b = buttons[i];
      if (mx.withinI(b.x, b.x + (b.big != null ? 24 : 16) - 1)
        && my.withinI(b.y, b.y + (b.big != null ? 24 : 16) - 1)) {
        mouseAction = Button(i);
        r(); return true;
      }
    }
    
    // stats
    if (mx.withinI(0, stats.bg.width - 1) && my.withinI(stats.y, 300)) {
      mouseAction = Stats;
      for (t in stats.tooltips) {
        if (mx.withinI(t.x, t.x + t.w - 1) && my.withinI(stats.y - 32 + t.y, stats.y - 32 + t.y + t.h - 1)) {
          mouseAction = StatsTooltip(t);
          r(); return true;
        }
      }
      r(); return true;
    }
    
    // map interaction
    var tile = mapRenderer.mouseToTile(mx, my);
    if (tile == null || tile.terrain == TTNone) {
      r(); return false;
    }
    mouseAction = SelectTile(tile);
    r(); return true;
  }
  
  public function keyUp(key:Key):Bool {
    if (handlingUpdate != null || selection == GameOver) return true;
    switch (key) {
      case Space:
      localController.queuedActions.push(EndTurn);
      clearUI();
      case Tab:
      mapRenderer.hpBarShow.toggle();
      case _: return false;
    }
    return true;
  }
}

enum UIAction {
  None;
  SelectTile(t:Tile);
  CancelModal;
  ConfirmModal;
  Stats;
  StatsTooltip(tt:Tooltip);
  Button(i:Int);
}

enum UISelection {
  None;
  GameOver;
  STileBase(t:Tile, ts:Array<UISelection>, i:Int);
  STile(t:Tile);
  SUnit(u:Unit);
  SBuilding(b:Building);
  BuildGround(b:Building, c:UISelection);
  BuildWater(b:Building, c:UISelection);
  BuildFlying(b:Building, c:UISelection);
  Sacrifice(b:Building, c:UISelection);
  Surrender(c:UISelection);
}

enum ModalTarget {
  MTPosition(x:Int, y:Int);
  MTTile(t:Tile);
  MTCenter;
}

typedef TooltipProto = {
     ?bg:Bitmap
    ,?has:Unit->Bool
    ,name:String
    ,?t:String
  };

typedef Tooltip = {
     x:Int
    ,y:Int
    ,w:Int
    ,h:Int
    ,tt:TooltipProto
    ,?click:Void->Void
  };
