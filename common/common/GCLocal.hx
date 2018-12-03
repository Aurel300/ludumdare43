package common;

class GCLocal implements GameController {
  public var queuedUpdates:Array<GameUpdate> = [];
  
  public function new() {
    
  }
  
  public function beginGame(g:Game):Void {
    queuedUpdates = [];
  }
  
  public function tick(g:Game):Void {
    function handleMoveUnit(u:Unit, to:Tile):Void {
      u.stats.moved = true;
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
      switch (action) {
        case Attack(target):
        var dmgA = u.damageTo(target, true);
        queuedUpdates.push(AttackUnit(u, target, dmgA, true));
        if (target.stats.HP - dmgA <= 0) {
          queuedUpdates.push(RemoveUnit(target));
        } else if (!target.stats.defended) {
          var dmgD = target.damageTo(u, false);
          if (dmgD > 0 && target.stats.RNG >= target.tile.position.distance(u.tile.position)) {
            queuedUpdates.push(AttackUnit(target, u, dmgD, false));
            if (u.stats.HP - dmgD <= 0) {
              queuedUpdates.push(RemoveUnit(u));
            }
          }
        }
        case Repair(target):
        var rep = (target.stats.maxHP - target.stats.HP).minI(2);
        queuedUpdates.push(RepairUnit(u, target, rep));
        case Capture(target):
        queuedUpdates.push(CaptureBuilding(target, u.owner));
      }
    }
    var stop = false;
    while (!stop) g.state = (switch (g.state) {
        case Starting(0): StartingTurn(g.players[0]);
        case Starting(t): Starting(t - 1);
        case StartingTurn(p):
        p.controller.beginTurn(p);
        // TODO: synchronise state if network
        for (tile in g.map.tiles) {
          for (unit in tile.units) {
            if (unit.owner != p) continue;
            unit.startingTile = tile;
            unit.stats.moved = false;
            unit.stats.acted = false;
            unit.stats.defended = false;
            unit.stats.MP = unit.stats.maxMP;
          }
        }
        PlayerTurn(p, Game.TURN_TIME);
        case PlayerTurn(p, 0): FinishingTurn(p);
        case PlayerTurn(p, t):
        switch (p.controller.pollAction(p)) {
          case Wait: stop = true;
          case MoveUnit(u, to): handleMoveUnit(u, to);
          case UnitAction(u, action): handleUnitAction(u, action);
          case EndTurn: g.state = FinishingTurn(p); continue;
        }
        PlayerTurn(p, t - 1);
        case FinishingTurn(p):
        p.controller.endTurn(p);
        // TODO: check victory
        
        // TODO: synchronise state if network
        StartingTurn(g.players[(g.players.indexOf(p) + 1) % g.players.length]);
        //case GameOver(winner):
        case _: stop = true; g.state;
      });
  }
  
  public function pollUpdate(g:Game):Null<GameUpdate> {
    if (queuedUpdates.length == 0) return null;
    var update = queuedUpdates.shift();
    switch (update) {
      case MoveUnit(u, from, to, cost):
      u.tile.units.remove(u);
      u.tile = g.map.get(to);
      u.tile.units.push(u);
      u.stats.MP -= cost;
      case AttackUnit(u, target, dmg, attacking):
      if (!attacking) u.stats.defended = true;
      target.stats.HP -= dmg;
      case RemoveUnit(u):
      u.tile.units.remove(u);
      case RepairUnit(_, target, rep):
      target.stats.HP += rep;
      case CaptureBuilding(b, by):
      b.owner = by;
    }
    return update;
  }
}
