package common;

class Building {
  public var type:BuildingType;
  public var tile:Tile;
  public var owner:Player;
  
  public var name(get, never):String;
  private function get_name():String return switch (type) {
      case BTTempleTron: "Temple-tron";
      case BTFactoreon: "Factoreon";
      case BTDock: "Dock";
      case BTEyrie: "Eyrie";
      case BTForge: "Forge";
      case BTFortress: "Fortress";
      case BTShrine: "Shrine";
    };
  
  public var captureCost(get, never):Int;
  private function get_captureCost():Int {
    var normal = (switch (type) {
        case BTTempleTron: 4;
        case BTFactoreon: 2;
        case BTDock: 3;
        case BTEyrie: 2;
        case BTForge: 3;
        case BTFortress: 2;
        case BTShrine: 3;
      });
    return (owner == null ? normal : ((normal + 1) >> 1));
  }
  
  public function new(type:BuildingType, tile:Tile, owner:Player) {
    this.type = type;
    this.tile = tile;
    this.owner = owner;
  }
  
  public function summariseBuild(of:UnitType) {
    var count = 0;
    for (t in tile.map.tiles) {
      for (u in t.units) if (u.type == of && u.owner == owner) count++;
    }
    
    var stats = of.stats(null);
    var suffCost = owner.cycles >= stats.CYC;
    var suffTier = owner.tier >= stats.tier;
    var ltMax = count < stats.maxCount;
    var space = tile.units.length == 0;
    
    return {
         canBuild: suffCost && suffTier && space && ltMax
        ,suffCost: suffCost
        ,suffTier: suffTier
        ,space: space
        ,ltMax: ltMax
        ,cost: stats.CYC
      };
  }
}
