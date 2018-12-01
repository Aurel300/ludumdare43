package common;

class Tile {
  public var terrain:Terrain;
  public var units:Array<Unit>;
  public var buildings:Array<Building>;
  public var owner:Player;
  public var map:Map;
  public var neighbours:Array<Tile>;
}
