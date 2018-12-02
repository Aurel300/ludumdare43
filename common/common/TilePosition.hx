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
    var x = tp.x - (tp.y >> 1);
    var z = tp.y;
    var y = -x - z;
    return {x: x, y: y, z: z};
  }
  
  public static function cubeToTp(cube:TilePositionCube):TilePosition {
    var x = cube.x - Std.int((cube.z + (cube.z & 1)) / 2);
    var y = cube.z;
    return {x: x, y: y};
  }
  
  public static function axialToCube<T:Float>(tp:{x:T, y:T}):{x:T, y:T, z:T} {
    var x = tp.x;
    var z = tp.y;
    var y = -x - z;
    return {x: x, y: y, z: z};
  }
  
  public static function cubeToAxial(tp:TilePositionCube):TilePosition {
    return {x: tp.x, y: tp.z};
  }
  
  public static function axialToPixel<T:Float>(tp:{x:T, y:T}):{x:T, y:T} {
    return {
         x: tp.x * 18
        ,y: -tp.x * 6 + tp.y * 12
      };
  }
  
  public static function pixelToAxial(tp:TilePosition):{x:Float, y:Float} {
    return {
         x: tp.x / 18
        ,y: tp.x / 36 + tp.y / 12
      };
  }
  
  public static function cubeRound(cube:{x:Float, y:Float, z:Float}):TilePositionCube {
    var rx = cube.x.round();
    var ry = cube.y.round();
    var rz = cube.z.round();
    
    var xDiff = (rx - cube.x).absF();
    var yDiff = (ry - cube.y).absF();
    var zDiff = (rz - cube.z).absF();
    
    if (xDiff > yDiff && xDiff > zDiff) {
      rx = -ry - rz;
    } else if (yDiff > zDiff) {
      ry = -rx - rz;
    } else {
      rz = -rx - ry;
    }
    
    return {x: rx, y: ry, z: rz};
  }
  
  public static function cubeSub(a:TilePositionCube, b:TilePositionCube):TilePositionCube {
    return {x: a.x - b.x, y: a.y - b.y, z: a.z - b.z};
  }
  
  public static function distance(a:TilePosition, b:TilePosition):Int {
    return cubeDistance(tpToCube(a), tpToCube(b));
  }
  
  public static function cubeDistance(a:TilePositionCube, b:TilePositionCube):Int {
    var dist = (a.x - b.x).absI();
    var dy = (a.y - b.y).absI();
    var dz = (a.z - b.z).absI();
    if (dy > dist) dist = dy;
    if (dz > dist) dist = dz;
    return dist;
  }
  
  public static var oddrDirections = [
       [[-1, -1], [ 0, -1], [-1,  0], [ 1,  0], [-1,  1], [ 0,  1]]
      ,[[ 0, -1], [ 1, -1], [-1,  0], [ 1,  0], [ 0,  1], [ 1,  1]]
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
