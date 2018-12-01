package common;

@:enum
abstract Terrain(Int) from Int to Int {
  var TTPlain = 0;
  var TTDesert = 1;
  var TTHill = 2;
  var TTMountain = 3;
  var TTWater = 4;
  var TTVoid = 5;
}

class TerrainTools {
  public static function tdf(of:Terrain, f:UnitCategory):InfInt return switch (f) {
      case Ground: tdfG(of);
      case _: Inf;
    };
  
  public static function tdfG(of:Terrain):InfInt return switch (of) {
      case TTPlain: Num(1);
      case TTDesert: Num(2);
      case TTHill: Num(2);
      case TTMountain: Num(3);
      case TTWater: Inf;
      case TTVoid: Inf;
    };
}
