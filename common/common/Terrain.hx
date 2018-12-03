package common;

@:enum
abstract Terrain(Int) from Int to Int {
  var TTPlain = 0;
  var TTDesert = 1;
  var TTHill = 2;
  var TTMountain = 3;
  var TTWater = 4;
  var TTVoid = 5;
  var TTNone = 6;
}

class TerrainTools {
  public static function tdf(of:Terrain, f:UnitCategory):InfInt return switch (f) {
      case Ground: tdfG(of);
      case Flying: tdfF(of);
      case Swimming: tdfS(of);
      case Amphibian: tdfA(of);
      case _: Inf;
    };
  
  public static function tdfG(of:Terrain):InfInt return switch (of) {
      case TTPlain: Num(1);
      case TTDesert: Num(2);
      case TTHill: Num(2);
      case TTMountain: Num(3);
      case _: Inf;
    };
  
  public static function tdfF(of:Terrain):InfInt return switch (of) {
      case TTMountain: Num(2);
      case TTNone: Inf;
      case _: Num(1);
    };
  
  public static function tdfS(of:Terrain):InfInt return switch (of) {
      case TTWater: Num(1);
      case _: Inf;
    };
  
  public static function tdfA(of:Terrain):InfInt return switch (of) {
      case TTPlain: Num(1);
      case TTDesert: Num(2);
      case TTHill: Num(2);
      case TTMountain: Num(3);
      case TTWater: Num(1);
      case _: Inf;
    };
  
  public static function variations(of:Terrain):Int return switch (of) {
      case TTPlain: 4;
      case TTDesert: 4;
      case TTHill: 4;
      case TTMountain: 4;
      case TTWater: 5;
      case _: 1;
    };
  
  public static function height(of:Terrain):Int return switch (of) {
      case TTHill: 2;
      case TTMountain: 4;
      case _: 0;
    };
}
