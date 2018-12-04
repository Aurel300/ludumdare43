package common;

class Player {
  public static final INIT_CYCLES = 6;
  
  public var name:String;
  public var colourIndex:Int = 2;
  public var faction:Faction;
  public var controller:PlayerController;
  public var cycles:Int;
  public var lastCycleGain:Int = 0;
  public var tier:Int = 0;
  public var lost:Bool = false;
  
  public function new(name:String, faction:Faction, controller:PlayerController) {
    this.name = name;
    this.faction = faction;
    this.controller = controller;
    cycles = INIT_CYCLES;
  }
}
