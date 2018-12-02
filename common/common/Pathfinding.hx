package common;

class Pathfinding {
  public static function getPath(
     from:Tile
    ,to:Tile
    ,?cost:Tile->Tile->InfInt
    ,?maxCost:Int
    ,?heuristic:Tile->Int
  ):Array<Tile> {
    if (cost == null) cost = ((a, b) -> Num(a == b ? 0 : 1));
    if (heuristic == null) heuristic = at -> at.position.distance(to.position);
    var map = from.map;
    var augMap:Vector<PFPathTile> = map.tiles.map(NotVisited);
    function augGet(tp:TilePosition):Null<PFPathTile> {
      if (!tp.x.withinI(0, map.width - 1) || !tp.y.withinI(0, map.height - 1)) return null;
      return augMap[tp.x + tp.y * map.width];
    }
    function augSet(tp:TilePosition, t:PFPathTile):Void {
      if (!tp.x.withinI(0, map.width - 1) || !tp.y.withinI(0, map.height - 1)) return;
      augMap[tp.x + tp.y * map.width] = t;
    }
    augSet(from.position, Visited(from, from, 0));
    var queue:Array<PFQueued> = [{t: from, from: from, cost: 0}];
    while (queue.length > 0) {
      var bestIdx = queue.streamArray().minIdx(q -> heuristic(q.t));
      var curQueue = queue.splice(bestIdx, 1)[0];
      for (n in curQueue.t.position.neighbours().map(augGet)) if (n != null) {
        var target = (switch (n) {
            case NotVisited(t) | Visited(t, _, _): t;
            case _: throw "?";
          });
        var newCost = curQueue.cost + (switch (cost(curQueue.t, target)) {
            case Num(n): n;
            case Inf: continue;
          });
        if (maxCost != null && newCost > maxCost) continue;
        switch (n) {
          case NotVisited(t) | Visited(t, _, newCost < _ => true):
          queue.push({t: t, from: curQueue.t, cost: newCost});
          augSet(t.position, Visited(t, curQueue.t, newCost));
          case Visited(_, _, _):
          case _: throw "?";
        }
      }
    }
    return (switch (augGet(to.position)) {
        case Visited(t, from, cost):
        var cur = Visited(t, from, cost);
        var ret = [];
        while (true) switch (cur) {
          case Visited(t, from, cost):
          if (t.position.equals(from.position)) break;
          ret.push(t);
          cur = augGet(from.position);
          case _: break;
        }
        ret;
        case _: null;
      });
  }
  
  public static function getReach(
     from:Tile
    ,?cost:Tile->Tile->InfInt
    ,?maxCost:Int
  ):Array<Tile> {
    if (cost == null) cost = ((a, b) -> Num(a == b ? 0 : 1));
    var map = from.map;
    var augMap:Vector<PFPathTile> = map.tiles.map(NotVisited);
    function augGet(tp:TilePosition):Null<PFPathTile> {
      if (!tp.x.withinI(0, map.width - 1) || !tp.y.withinI(0, map.height - 1)) return null;
      return augMap[tp.x + tp.y * map.width];
    }
    function augSet(tp:TilePosition, t:PFPathTile):Void {
      if (!tp.x.withinI(0, map.width - 1) || !tp.y.withinI(0, map.height - 1)) return;
      augMap[tp.x + tp.y * map.width] = t;
    }
    var queue:Array<PFQueued> = [{t: from, from: from, cost: 0}];
    while (queue.length > 0) {
      var curQueue = queue.shift();
      for (n in curQueue.t.position.neighbours().map(augGet)) if (n != null) {
        var target = (switch (n) {
            case NotVisited(t) | Visited(t, _, _): t;
            case _: throw "?";
          });
        var newCost = curQueue.cost + (switch (cost(curQueue.t, target)) {
            case Num(n): n;
            case Inf: continue;
          });
        if (maxCost != null && newCost > maxCost) continue;
        switch (n) {
          case NotVisited(t) | Visited(t, _, newCost < _ => true):
          queue.push({t: t, from: curQueue.t, cost: newCost});
          augSet(t.position, Visited(t, curQueue.t, newCost));
          case Visited(_, _, _):
          case _: throw "?";
        }
      }
    }
    return [ for (i in 0...augMap.length) switch (augMap[i]) {
        case Visited(t, _, _): t;
        case _: continue;
      } ];
  }
}

typedef PFQueued = {t:Tile, from:Tile, cost:Int};

enum PFPathTile {
  NotVisited(t:Tile);
  Visited(t:Tile, from:Tile, cost:Int);
}
