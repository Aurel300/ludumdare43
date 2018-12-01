package common;

interface PlayerController {
  function beginTurn():Void;
  function pollAction():PlayerAction;
}
