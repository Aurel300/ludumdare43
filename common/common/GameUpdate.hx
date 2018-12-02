package common;

enum GameUpdate {
  MoveUnit(u:Unit, from:TilePosition, to:TilePosition, mpCost:Int);
  AttackUnit(au:Unit, du:Unit, dmg:Int, attack:Bool);
  RemoveUnit(u:Unit);
  CaptureBuilding(b:Building, by:Player);
}
