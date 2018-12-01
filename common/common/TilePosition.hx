package common;

// odd-r convention offset coordinates
typedef TilePosition = {
     x:Int
    ,y:Int
  };

typedef TilePositionCube = {
     x:Int
    ,y:Int
    ,z:Int
  };

class TilePositionTools {
  public static function tpToCube(tp:TilePosition):TilePositionCube {
    var x = tp.x - Std.int((tp.y - (tp.y & 1)) / 2);
    var z = tp.y;
    var y = - x - z;
    return {x: x, y: y, z: z};
  }
  
  public static function cubeToTp(cube:TilePositionCube):TilePosition {
    var x = cube.x + Std.int((cube.z - (cube.z & 1)) / 2);
    var y = cube.z;
    return {x: x, y: y};
  }
  
  public static function distance(a:TilePosition, b:TilePosition):Int {
    return cubeDistance(tpToCube(a), tpToCube(b));
  }
  
  public static function cubeDistance(a:TilePositionCube, b:TilePositionCube):Int {
    return Std.int(((a.x - b.x).absI() + (a.y - b.y).absI() + (a.z - b.z).absI()) / 2);
  }
  
  static var oddrDirections = [
       [[ 1,  0], [ 0, -1], [-1, -1], [-1,  0], [-1,  1], [ 0,  1]]
      ,[[ 1,  0], [ 1, -1], [ 0, -1], [-1,  0], [ 0,  1], [ 1,  1]]
    ];
  
  public static function neighbours(tp:TilePosition):Array<TilePosition> {
    return [ for (off in oddrDirections[tp.y & 1]) {x: tp.x + off[0], y: tp.y + off[1]} ];
  }
  
  public static function equals(a:TilePosition, b:TilePosition):Bool {
    return a.x == b.x && a.y == b.y;
  }
  
  public static function toPixel(tp:TilePosition):TilePosition {
    var parity = tp.y & 1;
    var rowPairs = Std.int(tp.y / 2);
    return {
         x: tp.x * 18 + parity * 18 + rowPairs * 18
        ,y: -tp.x * 6 + parity * 6 + rowPairs * 18
      };
  }
}
