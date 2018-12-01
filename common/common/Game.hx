package common;

class Game {
  public static var I:Game;
  public static final TURN_TIME:Int = 60 * 60;
  
  public var map:Map;
  public var players:Array<Player>;
  public var state:GameState;
  
  public function new() {
    I = this;
  }
  
  public function tick():Void {
    var stop = false;
    while (!stop) state = (switch (state) {
        case Starting(0): StartingTurn(players[0]);
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
        StartingTurn(players[(players.indexOf(p) + 1) % players.length]);
        //case GameOver(winner):
        case _: stop = true; state;
      });
  }
}

enum GameState {
  Starting(t:Int);
  StartingTurn(p:Player);
  PlayerTurn(p:Player, timer:Int);
  FinishingTurn(p:Player);
  GameOver(winner:Null<Player>);
}
