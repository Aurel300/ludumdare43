package common;

class Player {
  public static final INIT_CYCLES = 6;
  public static final FAVOUR_LIMIT = 15;
  
  public var name:String;
  public var colourIndex:Int = 2;
  public var faction:Faction;
  public var controller:PlayerController;
  public var cycles:Int;
  public var favour:Int = 0;
  public var sacrificed:Bool = false;
  public var lastCycleGain:Int = 0;
  public var tier:Int = 0;
  public var lost:Bool = false;
  public var vision:Vector<Bool>;
  
  public var favourReached(get, never):Bool;
  private function get_favourReached():Bool {
    return favour >= FAVOUR_LIMIT;
  }
  
  public function new(name:String, faction:Faction, controller:PlayerController) {
    this.name = name;
    this.faction = faction;
    this.controller = controller;
    cycles = INIT_CYCLES;
  }
  
  public function recomputeVision(tiles:Vector<Tile>):Void {
    if (vision == null || vision.length != tiles.length) vision = new Vector<Bool>(tiles.length);
    var units = [];
    var buildings = [];
    for (i in 0...tiles.length) {
      for (u in tiles[i].units) if (u.owner == this) units.push(u);
      for (b in tiles[i].buildings) if (b.owner == this) buildings.push(b);
    }
    for (i in 0...tiles.length) {
      var visible = false;
      for (b in buildings) {
        if (b.tile.position.equals(tiles[i].position)) {
          visible = true;
          break;
        }
      }
      if (!visible) for (u in units) {
        if (u.tile.position.distance(tiles[i].position) <= u.stats.VIS) {
          visible = true;
          break;
        }
      }
      vision[i] = visible;
    }
  }
}
