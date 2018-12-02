package game;

class UI {
  static final MOVE_TIME = 20;
  static final ATTACK_TIME = 15;
  
  public var mapRenderer:MapRenderer;
  public var localController:PCLocal;
  public var gameController:GameController;
  
  public var selection:UISelection = None;
  public var mouseAction:UIAction = None;
  
  public var handlingUpdate:Null<GameUpdate> = null;
  public var handlingTimer:Int = 0;
  
  public function new(mapRenderer:MapRenderer, localController:PCLocal, gameController:GameController) {
    this.mapRenderer = mapRenderer;
    this.localController = localController;
    this.gameController = gameController;
    localController.updateObservers.push(tick);
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
      case AttackUnit(u, du, _, _): u.offX = u.offY = 0; u.displayTile = null; u.actionRelevant = false; du.actionRelevant = false; done();
      case MoveUnit(u, _, _, _): u.offX = u.offY = 0; u.displayTile = null; u.actionRelevant = false; done();
      case _: done();
    }
  }
  
  public function render(to:Bitmap, mx:Int, my:Int):Void {
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
  
  public function mouseDown(mx:Int, my:Int):Bool { return false; }
  public function mouseUp(mx:Int, my:Int):Bool {
    if (handlingUpdate != null) return true;
    function handleUnitOrder(unit:Unit, target:Tile):Bool {
      var accessible = unit.accessibleTiles;
      var actions = unit.accessibleActions;
      if (unit.stats.acted) return false;
      if (unit.owner != localController.activePlayer) return false;
      for (action in actions) if (switch (action) {
          case Attack(u) | Repair(u): u.tile == target;
          case Capture(building): building.tile == target;
        }) {
          localController.queuedActions.push(UnitAction(unit, action));
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
    // handle overlays ...
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
      deselect();
      case _: return false;
    }
    return true;
  }
}

enum UIAction {
  None;
  SelectTile(t:Tile);
}

enum UISelection {
  None;
  STileBase(t:Tile, ts:Array<UISelection>, i:Int);
  STile(t:Tile);
  SUnit(u:Unit);
  SBuilding(b:Building);
}
