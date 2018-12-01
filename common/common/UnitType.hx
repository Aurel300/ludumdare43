package common;

enum UnitType {
  Melee;
  Ranged;
  Support;
  Flying;
}

class UnitTypeTools {
  public static inline function category(of:UnitType):UnitCategory return switch (of) {
      case Melee: Ground;
      case Ranged: Ground;
      case Support: Ground;
      case Flying: Flying;
    };
  
  public static inline function cost(of:UnitType, f:Faction):Int return switch [of, f] {
      case [Melee, _]: 6;
      case [Ranged, _]: 5;
      case [Support, _]: 4;
      case [Flying, _]: 8;
    };
  
  public static inline function maxHP(of:UnitType, f:Faction):Int return switch [of, f] {
      case [Melee, _]: 5;
      case [Ranged, _]: 3;
      case [Support, _]: 3;
      case [Flying, _]: 4;
    };
  
  public static inline function maxMP(of:UnitType, f:Faction):Int return switch [of, f] {
      case [Melee, _]: 3;
      case [Ranged, _]: 2;
      case [Support, _]: 3;
      case [Flying, _]: 5;
    };
}
