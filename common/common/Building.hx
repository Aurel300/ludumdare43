package common;

class Building {
  public var type:BuildingType;
  public var tile:Tile;
  public var owner:Player;
  
  public function new(type:BuildingType, tile:Tile, owner:Player) {
    this.type = type;
    this.tile = tile;
    this.owner = owner;
  }
}
