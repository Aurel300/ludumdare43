package common;

class Unit {
  public var type:UnitType;
  public var tile:Tile;
  public var startingTile:Tile;
  public var owner:Player;
  public var stats:UnitStats;
  
  // visuals only
  public var offX:Float = 0;
  public var offY:Float = 0;
  public var displayTile:Tile = null;
  public var prevHealth:Int = 0;
  public var hurtTimer:Int = 0;
  public var actionRelevant:Bool = false;
  
  public var accessibleTiles(get, never):Array<Tile>;
  private function get_accessibleTiles():Array<Tile> {
    if (stats.acted) return [tile];
    return Pathfinding.getReach(tile, cost, stats.MP).filter(t -> t.units.length == 0).concat([tile]);
  }
  
  public var accessibleActions(get, never):Array<UnitAction>;
  private function get_accessibleActions():Array<UnitAction> {
    if (stats.acted) return [];
    var ret = [];
    if (stats.RNG > 0) {
      ret = ret.concat(
          Pathfinding.getReach(tile, null, stats.RNG)
            .filter(t -> t.units.length != 0 && t.units[0].owner != owner && damageTo(t.units[0], true) > 0)
            .map(t -> UnitAction.Attack(t.units[0]))
        );
    }
    if (tile.buildings.length > 0 && tile.buildings[0].owner != owner) {
      ret.push(Capture(tile.buildings[0]));
    }
    if (stats.repair) {
      ret = ret.concat(
          tile.neighbours
            .filter(t -> t.units.length != 0 && t.units[0].owner == owner && t.units[0].stats.HP < t.units[0].stats.maxHP)
            .map(t -> UnitAction.Repair(t.units[0]))
        );
    }
    return ret;
  }
  
  public function new(type:UnitType, tile:Tile, owner:Player) {
    this.type = type;
    this.tile = tile;
    startingTile = tile;
    this.owner = owner;
    stats = type.stats(owner == null ? null : owner.faction);
    prevHealth = stats.HP;
  }
  
  public function damageTo(target:Unit, attacking:Bool):Int {
    if (attacking) {
      var dmg = 1.maxI(stats.ATK - target.stats.DEF);
      if (stats.charge) dmg += startingTile.position.distance(tile.position);
      if (stats.healthATK) dmg += stats.HP;
      return dmg;
    } else {
      if (stats.siege) return 0;
      return 0.maxI(stats.ATK - target.stats.DEF);
    }
  }
  
  public function cost(from:Tile, to:Tile):InfInt {
    var fromTDF = from.terrain.tdf(type.category());
    var toTDF = to.terrain.tdf(type.category());
    if (stats.affinity.indexOf(from.terrain) != -1) fromTDF = Num(1);
    if (stats.affinity.indexOf(to.terrain) != -1) toTDF = Num(1);
    return to.units.filter(u -> u.owner != owner).length > 0 ? Inf : fromTDF.max(toTDF);
  }
  
  public function pathTo(to:Tile):Array<Tile> {
    var ret = Pathfinding.getPath(tile, to, cost, stats.MP);
    ret.reverse();
    return ret;
  }
}
