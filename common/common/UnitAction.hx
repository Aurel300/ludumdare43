package common;

enum UnitAction {
  Attack(target:Unit);
  Repair(target:Unit);
  Capture(target:Building);
  CaptureUnit(target:Unit);
  AttackNoDamage(target:Unit);
}
