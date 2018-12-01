package common;

class Tile {
  public var terrain:Terrain;
  public var variation:Int;
  public var position:TilePosition;
  public var map:Map;
  
  public var units:Array<Unit> = [];
  public var buildings:Array<Building> = [];
  public var owner:Player;
  
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
  
  public function new(terrain:Terrain, variation:Int, position:TilePosition, map:Map) {
    this.terrain = terrain;
    this.variation = variation;
    this.position = position;
    this.map = map;
  }
}
