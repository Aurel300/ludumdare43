package game;

class UI {
  static final MOVE_TIME = 20;
  static final ATTACK_TIME = 15;
  static final REPAIR_TIME = 30;
  
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
      ,bg: null
    };
  public var mouseAction:UIAction = None;
  
  public var handlingUpdate:Null<GameUpdate> = null;
  public var handlingTimer:Int = 0;
  
  public function new(mapRenderer:MapRenderer, localController:PCLocal, gameController:GameController) {
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
      handlingTimer++;
      break;
      case AttackUnit(au, du, dmg, attack) if (handlingTimer < ATTACK_TIME):
      du.hurtTimer = dmg * 8;
      au.actionRelevant = true;
      du.actionRelevant = true;
      if (au.tile.position.distance(du.tile.position) <= 1) {
        applyOff(au, mkOff(au.tile.position, du.tile.position), au.tile.position, .5 * Timing.quartIn.getF(handlingTimer / ATTACK_TIME));
      } else {
        au.offY = -3 * Timing.quartOut.getF(handlingTimer / ATTACK_TIME);
      }
      handlingTimer++;
      break;
      case RepairUnit(u, target, rep) if (handlingTimer < REPAIR_TIME):
      u.actionRelevant = true;
      target.actionRelevant = true;
      applyOff(u, mkOff(u.tile.position, target.tile.position), u.tile.position, .7 * Timing.sineInOut.getF(handlingTimer / REPAIR_TIME));
      handlingTimer++;
      break;
      case RepairUnit(u, du, _) | AttackUnit(u, du, _, _):
      u.offX = u.offY = 0; u.displayTile = null; u.actionRelevant = false; du.actionRelevant = false; done();
      case MoveUnit(u, _, _, _): u.offX = u.offY = 0; u.displayTile = null; u.actionRelevant = false; done();
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
  }
  
  public function render(to:Bitmap, mx:Int, my:Int):Void {
    // show modal
    if (!modal.show.isOff) {
      GSGame.makeUIBox(to, modal.x, modal.y, modal.w, modal.h);
      if (!modal.show.isOn) {
        to.blitAlphaRect(
             GSGame.B_UI_BOX_CONFIRM[modal.confirmHeld ? 1 : 0]
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
             GSGame.B_UI_BOX_CONFIRM[modal.confirmHeld ? 1 : 0]
            ,modal.x + modal.confirmX
            ,modal.y + modal.confirmY
          );
        if (modal.highlightTimer < 5 * 4) {
          to.blitAlpha(
               GSGame.B_UI_BOX_CONFIRM[2 + (modal.highlightTimer >> 2)]
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
    var selText = (switch (selection) {
        case STileBase(t, ts, i): switch (ts[i]) {
          case STile(tt): "tile";
          case SUnit(u): "unit";
          case SBuilding(b): "building";
          case _: "?";
        }
        case _: "nothing";
      });
    Text.render(to, 8, 300 - 16, 'turn: ${localController.activePlayer.name}, selected: $selText');
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
    switch (selection) {
      case STileBase(t, ts, i): switch (ts[i]) {
        case STile(_): mapRenderer.range = [t];
        case SUnit(u):
        if (u.owner == localController.activePlayer) {
          mapRenderer.range = u.accessibleTiles;
          mapRenderer.actions = u.accessibleActions;
        } else {
          mapRenderer.range = [t];
        }
        case SBuilding(b): mapRenderer.range = [t];
        case _:
      }
      case None: mapRenderer.range = [];
      case _:
    }
  }
  
  function selectTile(sel:Tile):Void {
    // update selection
    function freshTile() return STileBase(sel, sel.units.map(SUnit).concat(sel.buildings.map(SBuilding)).concat([STile(sel)]), 0);
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
          case Attack(u) | Repair(u): u.tile == target;
          case Capture(b): b.tile == target;
        }) {
          showModal(
               () -> localController.queuedActions.push(UnitAction(unit, action))
              ,selection
              ,MTTile(unit.tile)
              ,switch (action) {
                  case Attack(u): "Attack unit\n(some more info)";
                  case Repair(u): "Repair unit\n(some more info)";
                  case Capture(b): "Capture building\n(some more info)";
                }
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
    
    // TODO: handle overlays ...
    
    // map interaction
    var tile = mapRenderer.mouseToTile(mx, my);
    if (tile == null) return false;
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
