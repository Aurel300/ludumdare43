package common;

enum Terrain {
  TTPlain;
  TTDesert;
  TTHill;
  TTMountain;
  TTWater;
  TTVoid;
  
  // visual only
  TTVariation(type:Terrain, n:Int);
}

class TerrainTools {
  public static inline function tdf(of:Terrain, f:UnitCategory):InfInt return switch (f) {
      case Ground: tdfG(of);
      case _: Inf;
    };
  
  public static inline function tdfG(of:Terrain):InfInt return switch (of) {
      case TTPlain: Num(1);
      case TTDesert: Num(2);
      case TTHill: Num(2);
      case TTMountain: Num(3);
      case TTWater: Inf;
      case TTVoid: Inf;
      case TTVariation(of, _): tdfG(of);
    };
}
