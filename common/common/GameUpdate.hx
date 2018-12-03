package common;

enum GameUpdate {
  MoveUnit(u:Unit, from:TilePosition, to:TilePosition, mpCost:Int);
  AttackUnit(au:Unit, du:Unit, dmg:Int, attack:Bool);
  RemoveUnit(u:Unit);
  RepairUnit(u:Unit, target:Unit, rep:Int);
  CaptureBuilding(u:Unit, b:Building, capture:Bool);
  CapturingBuilding(u:Unit, b:Building, capture:Bool, progress:Int);
}
