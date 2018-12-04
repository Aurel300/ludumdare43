package common;

class GCLocal implements GameController {
  public var queuedUpdates:Array<GameUpdate> = [];
  
  public function new() {
    
  }
  
  public function beginGame(g:Game):Void {
    queuedUpdates = [];
    for (p in g.players) p.cycles = Player.INIT_CYCLES;
  }
  
  public function tick(g:Game):Void {
    function handleMoveUnit(u:Unit, to:Tile):Void {
      u.stats.moved = true;
      u.stats.captureTimer = 0;
      var path = u.pathTo(to);
      var cur = u.tile;
      for (p in path) {
        var cost = (switch (u.cost(cur, p)) {
            case Num(n): n;
            case Inf: throw "?";
          });
        queuedUpdates.push(MoveUnit(u, cur.position, p.position, cost));
        cur = p;
      }
    }
    function handleUnitAction(u:Unit, action:UnitAction):Void {
      if (u.stats.acted) return;
      u.stats.acted = true;
      if (!action.match(Capture(_))) u.stats.captureTimer = 0;
      switch (action) {
        case Attack(target):
        var attack = u.summariseAttack(target);
        if (attack.willStrike) queuedUpdates.push(AttackUnit(u, target, attack.dmgA, true));
        if (attack.killD) queuedUpdates.push(RemoveUnit(target));
        if (attack.willTurn) queuedUpdates.push(TurnUnit(target));
        if (attack.willCounter) queuedUpdates.push(AttackUnit(target, u, attack.dmgD, false));
        if (attack.killA) queuedUpdates.push(RemoveUnit(u));
        case Repair(target):
        var repair = u.summariseRepair(target);
        queuedUpdates.push(RepairUnit(u, target, repair.rep));
        case Capture(target):
        var capture = u.summariseCapture(target);
        if (capture.captured) queuedUpdates.push(CaptureBuilding(u, target, capture.capture));
        else queuedUpdates.push(CapturingBuilding(u, target, capture.capture, capture.progress));
        case AttackNoDamage(_):
      }
    }
    function handleBuild(ut:UnitType, at:Building):Void {
      var build = at.summariseBuild(ut);
      queuedUpdates.push(BuildUnit(ut, at, build.cost));
    }
    var stop = false;
    while (!stop) g.state = (switch (g.state) {
        case Starting(0): StartingTurn(g.players[0]);
        case Starting(t): Starting(t - 1);
        case StartingTurn(p):
        p.controller.beginTurn(p);
        // TODO: synchronise state if network
        p.tier = 0;
        p.lastCycleGain = 0;
        p.lost = true;
        p.recomputeVision(g.map.tiles);
        for (tile in g.map.tiles) {
          for (building in tile.buildings) {
            if (building.owner != p) continue;
            switch (building.type) {
              case BTTempleTron: p.lost = false; p.lastCycleGain += 3;
              case BTShrine: p.lastCycleGain += 3;
              case BTForge: p.tier++;
              case _:
            }
          }
          for (unit in tile.units) {
            if (unit.owner != p) continue;
            unit.startingTile = tile;
            unit.stats.moved = false;
            unit.stats.acted = false;
            unit.stats.MP = unit.stats.maxMP;
          }
        }
        if (p.lost) {
          FinishingTurn(p);
        } else {
          p.cycles += p.lastCycleGain;
          PlayerTurn(p, Game.TURN_TIME);
        }
        case PlayerTurn(p, 0): FinishingTurn(p);
        case PlayerTurn(p, t):
        switch (p.controller.pollAction(p)) {
          case Wait: stop = true;
          case MoveUnit(u, to): handleMoveUnit(u, to);
          case UnitAction(u, action): handleUnitAction(u, action);
          case Build(ut, at): handleBuild(ut, at);
          case EndTurn: g.state = FinishingTurn(p); continue;
        }
        PlayerTurn(p, t - 1);
        case FinishingTurn(p):
        p.controller.endTurn(p);
        for (tile in g.map.tiles) {
          for (unit in tile.units) {
            if (unit.owner != p) continue;
            unit.stats.defended = false;
          }
        }
        // TODO: synchronise state if network
        var playing = g.players.filter(p -> !p.lost);
        if (playing.length <= 1) {
          queuedUpdates.push(GameOver(playing.length > 0 ? playing[0] : null));
          GameOver(playing.length > 0 ? playing[0] : null);
        } else {
          var i = g.players.indexOf(p);
          var next = null;
          for (off in 1...g.players.length) {
            var cp = g.players[(i + off) % g.players.length];
            if (playing.indexOf(cp) != -1) {
              next = cp;
            }
          }
          if (next == null) {
            queuedUpdates.push(GameOver(null));
            GameOver(null);
          } else StartingTurn(g.players[(g.players.indexOf(p) + 1) % g.players.length]);
        }
        case GameOver(winner): stop = true; g.state;
        case _: stop = true; g.state;
      });
  }
  
  public function pollUpdate(g:Game):Null<GameUpdate> {
    if (queuedUpdates.length == 0) {
      return null;
    }
    var update = queuedUpdates.shift();
    switch (update) {
      case MoveUnit(u, from, to, cost):
      if (u.owner != null) u.owner.recomputeVision(g.map.tiles);
      u.tile.units.remove(u);
      u.tile = g.map.get(to);
      u.tile.units.push(u);
      u.stats.MP -= cost;
      case AttackUnit(u, target, dmg, attacking):
      if (!attacking) u.stats.defended = true;
      target.stats.HP -= dmg;
      case RemoveUnit(u):
      if (u.owner != null) u.owner.recomputeVision(g.map.tiles);
      u.tile.units.remove(u);
      case RepairUnit(_, target, rep):
      target.stats.HP += rep;
      case TurnUnit(u):
      if (u.owner != null) u.owner.recomputeVision(g.map.tiles);
      u.owner = null;
      case CaptureBuilding(u, b, _):
      if (u.owner != null) u.owner.recomputeVision(g.map.tiles);
      if (b.owner != null) b.owner.recomputeVision(g.map.tiles);
      u.stats.captureTimer = 0;
      b.owner = (b.owner == null ? u.owner : null);
      case CapturingBuilding(u, b, _, prog):
      u.stats.captureTimer = prog;
      case BuildUnit(ut, at, cost):
      var u = new Unit(ut, at.tile, at.owner);
      if (u.owner != null) u.owner.recomputeVision(g.map.tiles);
      at.tile.units.push(u);
      if (ut == Hog) u.stats.HP = 1;
      u.stats.MP = 0;
      u.stats.moved = true;
      u.stats.acted = true;
      at.owner.cycles -= cost;
      case GameOver(w):
    }
    return update;
  }
}
