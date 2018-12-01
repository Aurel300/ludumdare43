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
  public static inline function tdfG(of:Terrain):TDF return switch (of) {
      case TTPlain: Num(1);
      case TTDesert: Num(2);
      case TTHill: Num(2);
      case TTMountain: Num(3);
      case TTWater: Inf;
      case TTVoid: Inf;
      case TTVariation(of, _): tdfG(of);
    };
}
