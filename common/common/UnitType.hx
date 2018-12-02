package common;

@:enum
abstract UnitType(Int) from Int to Int {
  var Bull = 0;
  var Chamois = 1;
  var BombardierAnt = 2;
  var Bat = 3;
  var Monkey = 4;
}

typedef UnitStatsProto = {
     CYC:Int
    ,HP:Int
    ,MP:Int
    ,ATK:Int
    ,RNG:Int
    ,DEF:Int
    ,VIS:Int
    ,STL:Int
    ,?charge:Bool
    ,?repair:Bool
    ,?affinity:Array<Terrain>
  };

class UnitTypeTools {
  public static inline function category(of:UnitType):UnitCategory return switch (of) {
      case Bat: Flying;
      case _: Ground;
    };
  
  static var TYPE_STATS:haxe.ds.Map<UnitType, UnitStatsProto> = [
       Bull => {CYC: 6, HP: 5, MP: 3, ATK: 2, RNG: 1, DEF: 1, VIS: 2, STL: 0, charge: true}
      ,Chamois => {CYC: 6, HP: 5, MP: 3, ATK: 0, RNG: 1, DEF: 1, VIS: 2, STL: 0, charge: true, affinity: [TTMountain, TTHill]}
      ,BombardierAnt => {CYC: 5, HP: 3, MP: 2, ATK: 2, RNG: 3, DEF: 0, VIS: 4, STL: 0}
      ,Bat => {CYC: 8, HP: 4, MP: 5, ATK: 2, RNG: 1, DEF: 0, VIS: 4, STL: 0}
      ,Monkey => {CYC: 4, HP: 3, MP: 3, ATK: 0, RNG: 0, DEF: 0, VIS: 3, STL: 0, repair: true}
    ];
  
  public static function stats(of:UnitType, f:Faction):UnitStats {
    var stats = TYPE_STATS[of];
    return {
         CYC: stats.CYC
        ,maxHP: stats.HP
        ,HP: stats.HP
        ,maxMP: stats.MP
        ,MP: stats.MP
        ,ATK: stats.ATK
        ,RNG: stats.RNG
        ,DEF: stats.DEF
        ,VIS: stats.VIS
        ,STL: stats.STL
        ,SLW: 0
        ,moved: false
        ,acted: false
        ,defended: false
        ,charge: stats.charge != null ? stats.charge : false
        ,repair: stats.repair != null ? stats.repair : false
        ,affinity: stats.affinity != null ? stats.affinity : []
      };
  }
  
  public static inline function cost(of:UnitType, f:Faction):Int return TYPE_STATS[of].CYC;
  public static inline function maxHP(of:UnitType, f:Faction):Int return TYPE_STATS[of].HP;
  public static inline function maxMP(of:UnitType, f:Faction):Int return TYPE_STATS[of].MP;
}
