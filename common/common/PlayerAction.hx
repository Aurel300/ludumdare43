package common;

enum PlayerAction {
  Wait;
  MoveUnit(u:Unit, to:Tile);
  UnitAction(u:Unit, action:UnitAction);
  Build(u:UnitType, at:Building);
  EndTurn;
}
