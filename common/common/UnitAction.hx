package common;

enum UnitAction {
  Attack(target:Unit);
  Repair(target:Unit);
  Capture(target:Building);
  
  AttackNoDamage(target:Unit);
}
