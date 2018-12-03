package common;

import haxe.io.Bytes;

class Map {
  public static var MAPS = {
      var raw = [
          "tutorial" => "BwAAAA4AAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAAMAAAAAAAAAAFAAAABQAAAAUAAAAFAAAAIAAAAIAAAQAAAAAAAAAAAAUAAAAFAAAABQAAAAUAAAAAAAAAMAAAAAABAQAAAAAABQAAAAUAAAAFAAAAIAAAAAEAAAAwAAAABQAAAAUAAAAFAAAABQAAABEAAAAQEAEAEQAAAAUAAAAFAAAABQAAAAEAAAAQAAAAAQAAAAUAAAAFAAAABQAAAAUAAAAFAAAAAQAAADAQAgAFAAAABQAAAAUAAAAFAAAABQAAAAAAAAAAAAAABQAAAAUAAAAFAAAABQAAAAUAAAAQAAAAgAACABAAAAAFAAAABQAAAAUAAAAFAAAAIAAAADAAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAA=="
        ];
      [ for (k in raw.keys()) k => haxe.crypto.Base64.decode(raw[k]) ];
    };
  
  public var tiles:Vector<Tile>;
  public var width:Int;
  public var height:Int;
  
  private static final MF_TERRAIN_SHIFT = 0;
  private static final MF_TERRAIN_MASK = 15; // 4 bits // 16 terrain types
  private static final MF_VARIATION_SHIFT = 4;
  private static final MF_VARIATION_MASK = 7; // 3 bits // 8 varations
  private static final MF_BUILDING_SHIFT = 7;
  private static final MF_BUILDING_MASK = 15; // 4 bits // none + 15 building types
  private static final MF_UNIT_SHIFT = 11;
  private static final MF_UNIT_MASK = 31; // 5 bits // none + 15 unit types
  private static final MF_OWNER_SHIFT = 16;
  private static final MF_OWNER_MASK = 7; // 3 bits // neutral + 4 player types
  
  public function new(?players:Array<Player>, ?file:Bytes) {
    if (file == null) return;
    decode(players, file);
  }
  
  public function decode(players:Array<Player>, file:Bytes) {
    var width = file.getInt32(0);
    var height = file.getInt32(4);
    if (width * height * 4 != file.length - 8) return;
    this.width = width;
    this.height = height;
    tiles = new Vector(width * height);
    for (i in 0...tiles.length) {
      var mf = file.getInt32(8 + i * 4);
      var terrain   = (mf >> MF_TERRAIN_SHIFT  ) & MF_TERRAIN_MASK  ;
      var variation = (mf >> MF_VARIATION_SHIFT) & MF_VARIATION_MASK;
      var building  = (mf >> MF_BUILDING_SHIFT ) & MF_BUILDING_MASK ;
      var unit      = (mf >> MF_UNIT_SHIFT     ) & MF_UNIT_MASK     ;
      var owner     = (mf >> MF_OWNER_SHIFT    ) & MF_OWNER_MASK    ;
      tiles[i] = new Tile(
           (cast terrain:Terrain)
          ,variation
          ,{x: i % width, y: (i / width).floor()}
          ,this
        );
      var ownerPlayer = (owner == 0 ? null : players[owner - 1]);
      if (building != 0) tiles[i].buildings = [new Building((cast building - 1:BuildingType), tiles[i], ownerPlayer)];
      if (unit != 0) tiles[i].units = [new Unit((cast unit - 1:UnitType), tiles[i], ownerPlayer)];
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
      var ownerPlayer = t.buildings.length == 0 && t.units.length == 0
        ? null
        : (t.buildings.length == 0 ? t.units[0].owner : t.buildings[0].owner);
      var mf = ((cast t.terrain:Int) << MF_TERRAIN_SHIFT)
        | (t.variation << MF_VARIATION_SHIFT)
        | ((t.buildings.length == 0 ? 0 : 1 + (cast t.buildings[0].type:Int)) << MF_BUILDING_SHIFT)
        | ((t.units.length == 0 ? 0 : 1 + (cast t.units[0].type:Int)) << MF_UNIT_SHIFT)
        | ((ownerPlayer == null ? 0 : ownerPlayer.colourIndex) << MF_OWNER_SHIFT);
      ret.setInt32(8 + i * 4, mf);
    }
    return ret;
  }
  
  public function getXY(x:Int, y:Int):Null<Tile> {
    if (!x.withinI(0, width - 1) || !y.withinI(0, height - 1)) return null;
    return tiles[x + y * width];
  }
  
  public inline function get(tp:TilePosition):Null<Tile> {
    return getXY(tp.x, tp.y);
  }
}
