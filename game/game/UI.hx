package game;

class UI {
  static final MOVE_TIME = 20;
  static final ATTACK_TIME = 15;
  static final REPAIR_TIME = 30;
  static final CAPTURE_TIME = 60;
  
  static var TOOLTIP:Array<{bg:Bitmap, i:Int, has:Unit->Bool, name:String, t:String}> = [
       {bg: null, i: 0, has: u -> u.stats.affinity.indexOf(Terrain.TTHill) != -1, name: "Mountain/Hill affinity", t: "No slowdown on mountains or hills."}
      ,{bg: null, i: 1, has: u -> u.stats.affinity.indexOf(Terrain.TTDesert) != -1, name: "Desert affinity", t: "No slowdown in desert."}
      ,{bg: null, i: 2, has: u -> u.stats.repair, name: "Repair", t: "Can repair friendly units, restoring 2HP per turn."}
      ,{bg: null, i: 3, has: u -> u.stats.camouflage, name: "Camouflage", t: "STL increased by remaining MOV at the end of turn."}
      ,{bg: null, i: 4, has: u -> u.stats.charge, name: "Charge", t: "ATK increased by 1 for each hex tile away from start."}
      ,{bg: null, i: 5, has: u -> u.stats.siege, name: "Siege", t: "Can only attack when MOV is full. Cannot counter-strike."}
      ,{bg: null, i: 6, has: u -> u.stats.healthATK, name: "Health attack", t: "ATK increased by current HP."}
      ,{bg: null, i: 7, has: u -> u.stats.kamikaze, name: "Kamikaze", t: "Attacking destroys self."}
      ,{bg: null, i: 8, has: u -> u.stats.medusaGaze, name: "Medusa gaze", t: "Any attacked unit instantly turns neutral."}
    ];
  
  public static function load():Void {
    for (t in TOOLTIP) {
      var b = Platform.createBitmap(150, 70 + 48, 0);
      Text.render(b, 4, 44, '${Text.t(t.i < 4 ? RegularGreen : RegularRed)}${t.name}${Text.t(Regular)}');
      b.blitAlpha(Text.justify(t.t, 150 - 8, Regular, 12), 4, 44 + 16);
      t.bg = b;
    }
  }
  
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
      ,tooltips: ([]:Array<Tooltip>)
    };
  
  public var handlingUpdate:Null<GameUpdate> = null;
  public var handlingTimer:Int = 0;
  
  public function new(mapRenderer:MapRenderer, localController:PCLocal, gameController:GameController) {
    stats.bg = Platform.createBitmap(150, 70 + 48, 0);
    this.mapRenderer = mapRenderer;
    this.localController = localController;
    this.gameController = gameController;
    localController.updateObservers.push(tick);
  }
  
  public function clearUI():Void {
    modal.show.setTo(false);
    deselect();
  }
  
  public function tick():Void {
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
      case _: done();
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
      });
    modal.w = (modal.targetW * Timing.quartInOut(modal.show.valueF)).round();
    modal.h = (modal.targetH * Timing.quartOut(modal.show.valueF)).round();
    modal.x = (tp.x - (modal.w >> 2)).clampI(0, 500 - modal.w);
    modal.y = (tp.y).clampI(0, 300 - modal.h);
    
    stats.show.tick();
  }
  
  public function render(to:Bitmap, mx:Int, my:Int):Void {
    // stats
    if (!stats.show.isOff) {
      stats.y = 300 - Timing.quartInOut.getI(stats.show.valueF, stats.gfx.height);
      to.blitAlpha(stats.gfx, 0, stats.y);
      switch (mouseAction) {
        case StatsTooltip(i): to.blitAlpha(TOOLTIP[i].bg, 0, stats.y - 32);
        case _: to.blitAlpha(stats.bg, 0, stats.y - 32);
      }
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
    
    // render
    Text.render(to, 158, 300 - 16, 'turn: ${localController.activePlayer.name}');
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
    if (localController.activePlayer != null) mapRenderer.rangeColour = localController.activePlayer.colourIndex;
    mapRenderer.actions = [];
    stats.show.setTo(false);
    switch (selection) {
      case STileBase(t, ts, i):
      stats.gfx = GSGame.B_STATS[ts.length - 1][i];
      stats.bg.fill(0);
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
        Text.render(stats.bg, stats.bg.width - 30, 44, "(TILE)", SmallYellow);
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
        Text.render(stats.bg, stats.bg.width - 30, 44, "(UNIT)", SmallYellow);
        if (u.owner == localController.activePlayer) {
          mapRenderer.range = u.accessibleTiles;
          mapRenderer.actions = u.accessibleActions;
        }
        var cx = stats.bg.width - 4 - 24;
        var cy = stats.bg.height - 4 - 24 - 7;
        for (tt in TOOLTIP) {
          if (!tt.has(u)) continue;
          stats.bg.blitAlpha(GSGame.B_PERK[tt.i], cx, cy);
          stats.tooltips.push({
               x: cx
              ,y: cy
              ,w: 24
              ,h: 24
              ,i: tt.i
            });
          cx -= 24;
        }
        var ATK = u.baseAttack();
        '${Text.tp(u.owner)}${u.name} ${Text.t(Small)}(${Text.tp(u.owner, false)}${u.owner == null ? "NEUTRAL" : u.owner.name}${Text.t(Small)})${Text.t(Regular)}'
        + '\n${Text.t(Small)} HP: ${Text.t(Regular)}${u.stats.HP}${Text.t(Small)}/${u.stats.maxHP}'
        + '\n${Text.t(Small)}MOV: ${Text.t(Regular)}${u.stats.MP}${Text.t(Small)}/${u.stats.maxMP}'
        + '\n${Text.t(Small)}ATK: ${Text.t(Regular)}${ATK}${Text.t(Small)}'
          + (u.stats.ATK == ATK
            ? ""
            : ' ${Text.t(SmallYellow)}(${u.stats.ATK}${ATK > u.stats.ATK ? "+" : "-"}${(ATK - u.stats.ATK).absI()})')
        + '\n${Text.t(Small)}RNG: ${Text.t(Regular)}${u.stats.RNG}${Text.t(Small)}'
        + '\n${Text.t(Small)}DEF: ${Text.t(Regular)}${u.stats.DEF}${Text.t(Small)}';
        case SBuilding(b):
        Text.render(stats.bg, stats.bg.width - 46, 44, "(BUILDING)", SmallYellow);
        '${Text.tp(b.owner)}${b.name} ${Text.t(Small)}(${Text.tp(b.owner, false)}${b.owner == null ? "NEUTRAL" : b.owner.name}${Text.t(Small)})${Text.t(Regular)}'
        ;
        case _: "";
      });
      Text.render(stats.bg, 4, 44, text);
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
      case _: return false;
    }
    return true;
  }
  public function mouseUp(mx:Int, my:Int):Bool {
    mouseMove(mx, my);
    modal.confirmHeld = false;
    
    if (handlingUpdate != null) return true;
    function handleUnitOrder(unit:Unit, target:Tile):Bool {
      var accessible = unit.accessibleTiles;
      var actions = unit.accessibleActions;
      if (unit.stats.acted) return false;
      if (unit.owner != localController.activePlayer) return false;
      for (action in actions) if (switch (action) {
          case Attack(u) | Repair(u) | AttackNoDamage(u): u.tile == target;
          case Capture(b): b.tile == target;
        }) {
          var confirmAction = () -> localController.queuedActions.push(UnitAction(unit, action));
          var text = (switch (action) {
              case Attack(u):
              var attack = unit.summariseAttack(u);
              'Attack ${Text.tp(u.owner)}${u.name}${Text.t(Regular)}'
              + (attack.willStrike
                ? '\n${Text.t(SmallYellow)}STRIKE'
                  + '\n${Text.t(Regular)} DMG: ${attack.dmgA}' + (attack.killD ? ' ${Text.t(SmallRed)}LETHAL' : "")
                : '')
              + (attack.willCounter
                ? '\n${Text.t(SmallYellow)}COUNTER-STRIKE'
                  + '\n${Text.t(Regular)} DMG: ${attack.dmgD}' + (attack.killA ? ' ${Text.t(SmallRed)}LETHAL' : "")
                : '\n${Text.t(SmallYellow)}NO COUNTER-STRIKE'
                  + (attack.killD ? '\n${Text.t(Regular)} ${Text.t(SmallYellow)}(Unit destroyed)' : "")
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
      case [STileBase(_, ts, i), SelectTile(target)]: switch (ts[i]) {
        case SUnit(u): if (!handleUnitOrder(u, target)) selectTile(target);
        case _: selectTile(target);
      }
      case [_, SelectTile(t)]: selectTile(t);
      case [_, Stats]: return true;
      case [_, StatsTooltip(_)]: return true;
      case [_, None]: return false;
    }
    return true;
  }
  
  public function mouseMove(mx:Int, my:Int):Bool {
    if (handlingUpdate != null) {
      // CURSOR: hourglass
      return true;
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
      return true;
    }
    
    if (mx.withinI(0, stats.bg.width - 1) && my.withinI(stats.y, 300)) {
      mouseAction = Stats;
      for (t in stats.tooltips) {
        if (mx.withinI(t.x, t.x + t.w - 1) && my.withinI(stats.y - 32 + t.y, stats.y - 32 + t.y + t.h - 1)) {
          mouseAction = StatsTooltip(t.i);
          return true;
        }
      }
      return true;
    }
    
    // map interaction
    var tile = mapRenderer.mouseToTile(mx, my);
    if (tile == null || tile.terrain == TTNone) return false;
    mouseAction = SelectTile(tile);
    return true;
  }
  
  public function keyUp(key:Key):Bool {
    if (handlingUpdate != null) return true;
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
  StatsTooltip(i:Int);
}

enum UISelection {
  None;
  STileBase(t:Tile, ts:Array<UISelection>, i:Int);
  STile(t:Tile);
  SUnit(u:Unit);
  SBuilding(b:Building);
}

enum ModalTarget {
  MTPosition(x:Int, y:Int);
  MTTile(t:Tile);
}

typedef Tooltip = {
     x:Int
    ,y:Int
    ,w:Int
    ,h:Int
    ,i:Int
  };
