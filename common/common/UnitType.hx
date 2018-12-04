package common;

@:enum
abstract UnitType(Int) from Int to Int {
  var Wolf = 0;
  var Bull = 1;
  var Chamois = 2;
  var Spider = 3;
  var BombardierAnt = 4;
  var Hog = 5;
  var Monkey = 6;
  var Bumblebee = 7;
  var Mosquito = 8;
  var Bat = 9;
  var Eagle = 10;
  var Squid = 11;
  var Octopus = 12;
  var Swordfish = 13;
  var Frog = 14;
  var Snake = 15;
  var Medusa = 16;
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
    ,tier:Int
    ,?capture:Bool
    ,?maxCount:Int
    ,?charge:Bool
    ,?repair:Bool
    ,?affinity:Array<Terrain>
    ,?weakStart:Bool
    ,?healthATK:Bool
    ,?kamikaze:Bool
    ,?siege:Bool
    ,?camouflage:Bool
    ,?medusaGaze:Bool
  };

class UnitTypeTools {
  public static function name(of:UnitType):String return switch (of) {
      case Wolf: "Wolf";
      case Bull: "Bull";
      case Chamois: "Chamois";
      case Spider: "Spider";
      case BombardierAnt: "BombardierAnt";
      case Hog: "Hog";
      case Monkey: "Monkey";
      case Bumblebee: "Bumblebee";
      case Mosquito: "Mosquito";
      case Bat: "Bat";
      case Eagle: "Eagle";
      case Squid: "Squid";
      case Octopus: "Octopus";
      case Swordfish: "Swordfish";
      case Frog: "Frog";
      case Snake: "Snake";
      case Medusa: "Medusa";
    };
  
  public static inline function category(of:UnitType):UnitCategory return switch (of) {
      case Bumblebee | Mosquito | Bat | Eagle: Flying;
      case Squid | Octopus | Swordfish: Swimming;
      case Frog | Snake | Medusa: Amphibian;
      case _: Ground;
    };
  
  public static var TYPE_STATS:haxe.ds.Map<UnitType, UnitStatsProto> = [
      /*
       Wolf          => {CYC: 4 , HP: 2 , MP: 3, ATK: 3, RNG: 1, DEF: 0, VIS: 3, STL: 0}
      ,Bull          => {CYC: 6 , HP: 5 , MP: 3, ATK: 2, RNG: 1, DEF: 1, VIS: 2, STL: 0, charge: true}
      ,Chamois       => {CYC: 6 , HP: 5 , MP: 3, ATK: 0, RNG: 1, DEF: 1, VIS: 2, STL: 0, charge: true, affinity: [TTMountain, TTHill]}
      ,Spider        => {CYC: 3 , HP: 2 , MP: 4, ATK: 1, RNG: 1, DEF: 0, VIS: 3, STL: 1, affinity: [TTDesert]}
      ,BombardierAnt => {CYC: 5 , HP: 3 , MP: 2, ATK: 2, RNG: 3, DEF: 0, VIS: 4, STL: 0, siege: true}
      ,Hog           => {CYC: 9 , HP: 10, MP: 1, ATK: 0, RNG: 1, DEF: 0, VIS: 2, STL: 0, weakStart: true, healthATK: true}
      ,Monkey        => {CYC: 4 , HP: 3 , MP: 3, ATK: 0, RNG: 0, DEF: 0, VIS: 3, STL: 0, repair: true}
      ,Bumblebee     => {CYC: 4 , HP: 1 , MP: 1, ATK: 6, RNG: 1, DEF: 0, VIS: 3, STL: 1, kamikaze: true, siege: true}
      ,Mosquito      => {CYC: 5 , HP: 2 , MP: 3, ATK: 2, RNG: 1, DEF: 0, VIS: 4, STL: 1}
      ,Bat           => {CYC: 8 , HP: 4 , MP: 4, ATK: 2, RNG: 1, DEF: 0, VIS: 4, STL: 0}
      ,Eagle         => {CYC: 10, HP: 5 , MP: 3, ATK: 3, RNG: 1, DEF: 1, VIS: 4, STL: 0}
      ,Squid         => {CYC: 4 , HP: 2 , MP: 3, ATK: 2, RNG: 3, DEF: 2, VIS: 4, STL: 2}
      ,Octopus       => {CYC: 6 , HP: 4 , MP: 4, ATK: 4, RNG: 1, DEF: 1, VIS: 3, STL: 1}
      ,Swordfish     => {CYC: 9 , HP: 2 , MP: 6, ATK: 0, RNG: 1, DEF: 1, VIS: 2, STL: 1, charge: true}
      ,Frog          => {CYC: 1 , HP: 1 , MP: 3, ATK: 0, RNG: 0, DEF: 2, VIS: 2, STL: 0}
      ,Snake         => {CYC: 7 , HP: 3 , MP: 3, ATK: 2, RNG: 1, DEF: 0, VIS: 3, STL: 0, camouflage: true}
      ,Medusa        => {CYC: 15, HP: 4 , MP: 3, ATK: 1, RNG: 2, DEF: 0, VIS: 4, STL: 1, medusaGaze: true}
      */
       Wolf          => {CYC: 4 , HP: 2 , MP: 3, ATK: 3, RNG: 1, DEF: 0, VIS: 3, STL: 0, capture: true, tier: 0}
      ,Bull          => {CYC: 10, HP: 6 , MP: 3, ATK: 2, RNG: 1, DEF: 1, VIS: 2, STL: 0, charge: true, tier: 3}
      ,Chamois       => {CYC: 6,  HP: 4 , MP: 4, ATK: 1, RNG: 1, DEF: 0, VIS: 2, STL: 0, charge: true, affinity: [TTMountain, TTHill], tier: 2}
      ,Spider        => {CYC: 4 , HP: 2 , MP: 4, ATK: 1, RNG: 1, DEF: 0, VIS: 3, STL: 1, affinity: [TTDesert], capture: true, tier: 1}
      ,BombardierAnt => {CYC: 6 , HP: 3 , MP: 2, ATK: 2, RNG: 4, DEF: 0, VIS: 1, STL: 0, siege: true, tier: 2}
      ,Hog           => {CYC: 9 , HP: 10, MP: 3, ATK: 0, RNG: 1, DEF: 0, VIS: 2, STL: 0, weakStart: true, healthATK: true, tier: 4, maxCount: 1}
      ,Monkey        => {CYC: 4 , HP: 1 , MP: 2, ATK: 0, RNG: 0, DEF: 2, VIS: 1, STL: 0, repair: true, affinity: [TTMountain, TTHill], capture: true, tier: 1, maxCount: 2}
      
      ,Bumblebee     => {CYC: 4 , HP: 1 , MP: 5, ATK: 6, RNG: 1, DEF: 0, VIS: 1, STL: 0, kamikaze: true, siege: true, tier: 2}
      ,Mosquito      => {CYC: 5 , HP: 2 , MP: 3, ATK: 3, RNG: 1, DEF: 0, VIS: 3, STL: 1, tier: 2}
      ,Bat           => {CYC: 5 , HP: 2 , MP: 8, ATK: 0, RNG: 0, DEF: 0, VIS: 4, STL: 0, tier: 0, maxCount: 1}
      ,Eagle         => {CYC: 10, HP: 5 , MP: 5, ATK: 3, RNG: 1, DEF: 1, VIS: 4, STL: 0, tier: 4}
      
      ,Squid         => {CYC: 10, HP: 2 , MP: 3, ATK: 4, RNG: 4, DEF: 2, VIS: 1, STL: 0, siege: true, tier: 2, maxCount: 2}
      ,Octopus       => {CYC: 6 , HP: 4 , MP: 3, ATK: 4, RNG: 1, DEF: 0, VIS: 3, STL: 1, tier: 1} 
      ,Swordfish     => {CYC: 9 , HP: 4 , MP: 6, ATK: 0, RNG: 1, DEF: 1, VIS: 2, STL: 1, charge: true, tier: 3, maxCount: 1}
      
      ,Frog          => {CYC: 2 , HP: 1 , MP: 1, ATK: 0, RNG: 0, DEF: 3, VIS: 1, STL: 0, tier: 1}
      ,Snake         => {CYC: 5 , HP: 3 , MP: 3, ATK: 2, RNG: 1, DEF: 0, VIS: 3, STL: 0, camouflage: true, capture: true, tier: 2}
      ,Medusa        => {CYC: 15, HP: 4 , MP: 3, ATK: 1, RNG: 2, DEF: 2, VIS: 3, STL: 0, medusaGaze: true, tier: 4, maxCount: 1}
    ];
  
  public static function stats(of:UnitType, f:Null<Faction>):UnitStats {
    var stats = TYPE_STATS[of];
    inline function db(b:Null<Bool>):Bool return b != null ? b : false;
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
        ,tier: stats.tier
        ,capture: db(stats.capture)
        ,maxCount: stats.maxCount != null ? stats.maxCount : 4
        ,moved: false
        ,acted: false
        ,defended: false
        ,captureTimer: 0
        ,charge: db(stats.charge)
        ,repair: db(stats.repair)
        ,affinity: stats.affinity != null ? stats.affinity : []
        ,weakStart: db(stats.weakStart)
        ,healthATK: db(stats.healthATK)
        ,kamikaze: db(stats.kamikaze)
        ,siege: db(stats.siege)
        ,camouflage: db(stats.camouflage)
        ,medusaGaze: db(stats.medusaGaze)
      };
  }
  
  public static inline function cost(of:UnitType, f:Faction):Int return TYPE_STATS[of].CYC;
  public static inline function maxHP(of:UnitType, f:Faction):Int return TYPE_STATS[of].HP;
  public static inline function maxMP(of:UnitType, f:Faction):Int return TYPE_STATS[of].MP;
}
