package common;

enum GameUpdate {
  MoveUnit(u:Unit, from:TilePosition, to:TilePosition, mpCost:Int);
  AttackUnit(au:Unit, du:Unit, dmg:Int, attack:Bool);
  RemoveUnit(u:Unit);
  RepairUnit(u:Unit, target:Unit, rep:Int);
  TurnUnit(u:Unit);
  CaptureBuilding(u:Unit, b:Building, capture:Bool);
  CaptureUnit(u:Unit, target:Unit);
  CapturingBuilding(u:Unit, b:Building, capture:Bool, progress:Int);
  BuildUnit(ut:UnitType, at:Building, cost:Int);
  GameOver(w:Player);
}
