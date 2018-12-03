package common;

@:enum
abstract BuildingType(Int) from Int to Int {
  var BTTempleTron = 0;
  var BTFactoreon = 1;
  var BTDock = 2;
  var BTEyrie = 3;
  var BTForge = 4;
  var BTFortress = 5;
  var BTShrine = 6;
}
