package common;

interface PlayerController {
  function beginTurn(p:Player):Void;
  function endTurn(p:Player):Void;
  function pollAction(p:Player):PlayerAction;
}
