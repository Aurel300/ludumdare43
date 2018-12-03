package common;

class Tile {
  public var terrain:Terrain;
  public var variation:Int;
  public var position:TilePosition;
  public var map:Map;
  
  public var units:Array<Unit> = [];
  public var buildings:Array<Building> = [];
  public var owner:Player;
  
  // visuals only
  public var offsetUnits:Array<Unit> = [];
  
  public var neighboursAll(get, never):Array<Tile>;
  private function get_neighboursAll():Array<Tile> {
    return [ for (t in position.neighbours().map(map.get)) t ];
  }
  
  public var neighbours(get, never):Array<Tile>;
  private function get_neighbours():Array<Tile> {
    return [ for (t in position.neighbours().map(map.get)) if (t != null) t ];
  }
  
  public var height(get, never):Int;
  private function get_height():Int {
    return terrain.height();
  }
  
  public var name(get, never):String;
  private function get_name():String return (switch (terrain) {
      case TTPlain: "Plains";
      case TTDesert: "Desert";
      case TTHill: "Hills";
      case TTMountain: "Mountains";
      case TTWater: "Water";
      case TTVoid: "Void";
      case TTNone: "None";
    });
  
  public function new(terrain:Terrain, variation:Int, position:TilePosition, map:Map) {
    this.terrain = terrain;
    this.variation = variation;
    this.position = position;
    this.map = map;
  }
  
  public function tdf(u:Unit):InfInt {
    var tdf = terrain.tdf(u.type.category());
    if (u.stats.affinity.indexOf(terrain) != -1) tdf = Num(1);
    if (u.type.category() == Swimming
      && buildings.length > 0
      && buildings[0].type == BTDock
      && buildings[0].owner == u.owner) tdf = Num(1);
    return tdf;
  }
}
