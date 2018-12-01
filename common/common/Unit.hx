package common;

class Unit {
  public var type:UnitType;
  public var tile:Tile;
  public var owner:Player;
  public var hp:Int;
  public var mp:Int;
  
  public var accessibleTiles(get, never):Array<Tile>;
  private function get_accessibleTiles():Array<Tile> {
    return Pathfinding.getReach(tile, cost, mp).filter(t -> t.units.length == 0);
  }
  
  public function new() {}
  
  public function cost(from:Tile, to:Tile):InfInt return
    to.units.filter(u -> u.owner != owner).length > 0
      ? Inf
      : from.terrain.tdf(type.category()).max(to.terrain.tdf(type.category()));
  
  public function pathTo(to:Tile):Array<Tile> return Pathfinding.getPath(tile, to, cost, mp);
}
