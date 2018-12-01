package common;

import haxe.io.Bytes;

class Map {
  public var tiles:Vector<Tile>;
  public var width:Int;
  public var height:Int;
  
  private static final MF_TERRAIN_SHIFT = 0;
  private static final MF_TERRAIN_MASK = 15; // 4 bits // 16 terrain types
  private static final MF_VARIATION_SHIFT = 4;
  private static final MF_VARIATION_MASK = 7; // 3 bits // 8 varations
  
  public function new(file:Bytes) {
    width = file.getInt32(0);
    height = file.getInt32(4);
    tiles = new Vector(width * height);
    for (i in 0...tiles.length) {
      var mf = file.getInt32(8 + i * 4);
      var terrain = (mf >> MF_TERRAIN_SHIFT) & MF_TERRAIN_MASK;
      var variation = (mf >> MF_VARIATION_SHIFT) & MF_VARIATION_MASK;
      tiles[i] = new Tile(
           (cast terrain:Terrain)
          ,variation
          ,{x: i % width, y: (i / width).floor()}
          ,this
        );
    }
  }
  
  public function encode():Bytes {
    var ret = Bytes.alloc(8 + tiles.length * 4);
    ret.setInt32(0, width);
    ret.setInt32(4, height);
    for (i in 0...tiles.length) {
      var t = tiles[i];
      if (t.units.length > 1) throw "?";
      if (t.buildings.length > 1) throw "?";
      var mf = ((cast t.terrain:Int) << MF_TERRAIN_SHIFT)
        | (t.variation << MF_VARIATION_SHIFT);
      ret.setInt32(8 + i * 4, mf);
    }
    return ret;
  }
  
  public function get(tp:TilePosition):Null<Tile> {
    if (!tp.x.withinI(0, width - 1) || !tp.y.withinI(0, height - 1)) return null;
    return tiles[tp.x + tp.y * width];
  }
}
