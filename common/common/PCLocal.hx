package common;

class PCLocal implements PlayerController {
  public var activePlayer:Player;
  public var queuedActions:Array<PlayerAction> = [];
  public var updateObservers:Array<Void->Void> = [];
  
  public function new() {}
  
  public function beginTurn(p:Player):Void {
    activePlayer = p;
    queuedActions = [];
  }
  
  public function endTurn(p:Player):Void {
    activePlayer = null;
    for (o in updateObservers) o();
  }
  
  public function pollAction(p:Player):PlayerAction {
    if (queuedActions.length > 0) return queuedActions.shift();
    return Wait;
  }
}
