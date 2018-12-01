package common;

class Tile {
  public var terrain:Terrain;
  public var position:TilePosition;
  public var units:Array<Unit>;
  public var buildings:Array<Building>;
  public var owner:Player;
  public var map:Map;
  
  public var neighbours(get, never):Array<Tile>;
  private function get_neighbours():Array<Tile> {
    return [ for (t in position.neighbours().map(map.get)) if (t != null) t ];
  }
}
