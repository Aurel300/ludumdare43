package common;

class PCLocal implements PlayerController {
  public function new() {}
  
  public function beginTurn(p:Player):Void {
    
  }
  
  public function endTurn(p:Player):Void {
    
  }
  
  public function pollAction(p:Player):PlayerAction {
    return Wait;
  }
}
