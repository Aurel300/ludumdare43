package common;

class Pathfinding {
  public static function getPath(
     from:Tile
    ,to:Tile
    ,?cost:Tile->Tile->InfInt
    ,?maxCost:Int
  ):Array<PFPathTile> {
    if (cost == null) cost = ((a, b) -> Num(a == b ? 0 : 1));
    function heuristic(at:Tile):Int return at.position.distance(to.position);
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
    var queue:Array<PFPathTile> = [Queued(from, from, 0)];
    while (queue.length > 0) switch (queue.shift()) {
      case Queued(current, from, curCost):
      for (n in current.position.neighbours().map(augGet)) if (n != null) {
        var target = (switch (n) {
            case NotVisited(t) | Visited(t, _, _): t;
            case _: throw "?";
          });
        var newCost = curCost + (switch (cost(current, target)) {
            case Num(n): n;
            case Inf: continue;
          });
        switch (n) {
          case NotVisited(t): augSet(t.position, Visited(t, current, newCost));
          case Visited(t, from, newCost < _ => true): augSet(t.position, Visited(t, current, newCost));
          case Visited(_, _, _):
          case _: throw "?";
        }
      }
      case _: throw "?";
    }
    return (switch (augGet(to.position)) {
        case Visited(t, from, cost):
        var cur = Visited(t, from, cost);
        var ret = [];
        while (true) switch (cur) {
          case Visited(t, from, cost):
          if (t.position.equals(from.position)) break;
          ret.push(cur);
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
    // Dijkstra
    return null;
  }
}

enum PFPathTile {
  NotVisited(t:Tile);
  Visited(t:Tile, from:Tile, cost:Int);
  Queued(t:Tile, from:Tile, cost:Int);
}
