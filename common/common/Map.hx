package common;

class Map {
  public var tiles:Vector<Tile>;
  public var width:Int;
  public var height:Int;
  
  public function get(tp:TilePosition):Null<Tile> {
    if (!tp.x.withinI(0, width - 1) || !tp.y.withinI(0, height - 1)) return null;
    return tiles[tp.x + tp.y * width];
  }
}
