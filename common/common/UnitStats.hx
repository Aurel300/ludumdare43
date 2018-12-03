package common;

typedef UnitStats = {
     CYC:Int
    ,maxHP:Int
    ,HP:Int
    ,maxMP:Int
    ,MP:Int
    ,ATK:Int
    ,RNG:Int
    ,DEF:Int
    ,VIS:Int
    ,STL:Int
    ,moved:Bool
    ,acted:Bool
    ,defended:Bool
    ,captureTimer:Int
    ,tier:Int //
    ,capture:Bool // units
    ,maxCount:Int //
    ,charge:Bool
    ,repair:Bool
    ,affinity:Array<Terrain>
    ,weakStart:Bool //
    ,healthATK:Bool
    ,kamikaze:Bool
    ,siege:Bool
    ,camouflage:Bool //
    ,medusaGaze:Bool
  };
