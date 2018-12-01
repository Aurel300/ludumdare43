package common;

interface PlayerController {
  function beginTurn():Void;
  function endTurn():Void;
  function pollAction():PlayerAction;
}
