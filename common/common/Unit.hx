package common;

class Unit {
  public var type:UnitType;
  public var tile:Tile;
  public var owner:Player;
  public var stats:UnitStats;
  
  public var accessibleTiles(get, never):Array<Tile>;
  private function get_accessibleTiles():Array<Tile> {
    return Pathfinding.getReach(tile, cost, stats.MP).filter(t -> t.units.length == 0).concat([tile]);
  }
  
  public function new(type:UnitType, tile:Tile, owner:Player) {
    this.type = type;
    this.tile = tile;
    this.owner = owner;
    stats = type.stats(owner.faction);
  }
  
  public function cost(from:Tile, to:Tile):InfInt {
    var fromTDF = from.terrain.tdf(type.category());
    var toTDF = to.terrain.tdf(type.category());
    if (stats.affinity.indexOf(from.terrain) != -1) fromTDF = Num(1);
    if (stats.affinity.indexOf(to.terrain) != -1) toTDF = Num(1);
    return to.units.filter(u -> u.owner != owner).length > 0 ? Inf : fromTDF.max(toTDF);
  }
  
  public function pathTo(to:Tile):Array<Tile> return Pathfinding.getPath(tile, to, cost, stats.MP);
}
