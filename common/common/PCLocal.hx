package common;

class PCLocal implements PlayerController {
  public function new() {}
  
  public function beginTurn():Void {
    
  }
  
  public function pollAction():PlayerAction {
    return EndTurn;
  }
}
