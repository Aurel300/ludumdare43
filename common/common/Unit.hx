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
            .filter(t -> t.units.length != 0 && canAttack(t.units[0], true))
            .map(t -> damageTo(t.units[0], true) > 0 ? UnitAction.Attack(t.units[0]) : UnitAction.AttackNoDamage(t.units[0]))
        );
    }
    if (tile.buildings.length > 0 && canCapture(tile.buildings[0])) {
      ret.push(Capture(tile.buildings[0]));
    }
    if (stats.repair) {
      ret = ret.concat(
          tile.neighbours
            .filter(t -> t.units.length != 0 && canRepair(t.units[0]))
            .map(t -> UnitAction.Repair(t.units[0]))
        );
    }
    return ret;
  }
  
  public var name(get, never):String;
  private function get_name():String return switch (type) {
      case Wolf: "Wolf";
      case Bull: "Bull";
      case Chamois: "Chamois";
      case Spider: "Spider";
      case BombardierAnt: "Bombardier Ant";
      case Hog: "Hog";
      case Monkey: "Monkey";
      case Bumblebee: "Bumblebee";
      case Mosquito: "Mosquito";
      case Bat: "Bat";
      case Eagle: "Eagle";
      case Squid: "Squid";
      case Octopus: "Octopus";
      case Swordfish: "Swordfish";
      case Frog: "Frog";
      case Snake: "Snake";
      case Medusa: "Medusa";
    };
  
  public function new(type:UnitType, tile:Tile, owner:Player) {
    this.type = type;
    this.tile = tile;
    startingTile = tile;
    this.owner = owner;
    stats = type.stats(owner == null ? null : owner.faction);
    prevHealth = stats.HP;
  }
  
  public function summariseAttack(target:Unit) {
    var dmgA = damageTo(target, true);
    var willStrike = true;
    var killD = false;
    var dmgD = target.damageTo(this, false);
    var willCounter = false;
    var killA = false;
    
    if (target.stats.HP - dmgA <= 0) {
      killD = true;
    } else if (dmgD > 0 && target.canAttack(this, false)) {
      willCounter = true;
      if (stats.HP - dmgD <= 0) {
        killA = true;
      }
    }
    
    return {
         dmgA: dmgA
        ,willStrike: willStrike
        ,killD: killD
        ,dmgD: willCounter ? dmgD : 0
        ,willCounter: willCounter
        ,killA: killA
      };
  }
  
  public function summariseRepair(target:Unit) {
    var rep = (target.stats.maxHP - target.stats.HP).minI(2);
    var full = (target.stats.HP + rep) >= target.stats.maxHP;
    return {
         rep: rep
        ,full: full
      };
  }
  
  public function summariseCapture(target:Building) {
    var progress = stats.captureTimer + 1;
    return {
         captured: progress >= target.captureCost
        ,start: stats.captureTimer == 0
        ,progress: progress
        ,turnsLeft: target.captureCost - stats.captureTimer
        ,capture: target.owner == null
      };
  }
  
  public function canAttack(target:Unit, attack:Bool, ?from:Tile):Bool {
    if (from == null) from = tile;
    var dist = target.tile.position.distance(from.position);
    return stats.RNG + stats.VIS >= dist - target.stats.STL
      && stats.RNG >= dist
      && baseAttack() > 0
      && target.owner != null
      && target.owner != owner
      && (attack ? true : !stats.siege)
      && (attack ? true : !stats.defended);
  }
  
  public function canRepair(target:Unit):Bool {
    var dist = target.tile.position.distance(tile.position);
    return dist == 1
      && target.stats.HP < target.stats.maxHP
      && target.owner == owner;
  }
  
  public function canCapture(target:Building):Bool {
    return target.tile.position.equals(tile.position)
      && stats.capture
      && target.owner != owner;
  }
  
  public function baseAttack():Int {
    var dmg = stats.ATK;
    if (stats.charge) dmg += startingTile.position.distance(tile.position);
    if (stats.healthATK) dmg += stats.HP;
    return dmg;
  }
  
  public function damageTo(target:Unit, attacking:Bool):Int {
    return 0.maxI(if (attacking) {
        baseAttack() - target.stats.DEF;
      } else {
        if (stats.siege) 0;
        else baseAttack() - target.stats.DEF;
      });
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
