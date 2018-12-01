package common;

class GCLocal implements GameController {
  public function new() {
    
  }
  
  public function beginGame(g:Game):Void {
    
  }
  
  public function tick(g:Game):Void {
    var stop = false;
    while (!stop) g.state = (switch (g.state) {
        case Starting(0): StartingTurn(g.players[0]);
        case Starting(t): Starting(t - 1);
        case StartingTurn(p):
        p.controller.beginTurn();
        // TODO: synchronise state if network
        PlayerTurn(p, TURN_TIME);
        case PlayerTurn(p, 0): FinishingTurn(p);
        case PlayerTurn(p, t): switch (p.controller.pollAction()) {
            case Wait: stop = true; PlayerTurn(p, t - 1);
            case EndTurn: FinishingTurn(p);
          };
        case FinishingTurn(p):
        p.controller.endTurn();
        // TODO: synchronise state if network
        // TODO: check victory
        StartingTurn(g.players[(g.players.indexOf(p) + 1) % g.players.length]);
        //case GameOver(winner):
        case _: stop = true; state;
      });
  }
}
