package common;

interface GameController {
  function beginGame(g:Game):Void;
  function tick(g:Game):Void;
  function pollUpdate(g:Game):Null<GameUpdate>;
}
