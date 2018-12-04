package common;

class Game {
  public static var I:Game;
  public static final TURN_TIME:Int = 60 * 60;
  
  public var map:Map;
  public var players:Array<Player>;
  public var state:GameState;
  public var controller:GameController;
  
  public var turnTimer(get, never):Int;
  private function get_turnTimer():Int return switch (state) {
      case PlayerTurn(_, timer): timer;
      case _: 0;
    };
  
  public function new(map:Map, players:Array<Player>, controller:GameController) {
    this.map = map;
    this.players = players;
    for (i in 0...players.length) players[i].colourIndex = i + 1;
    state = Starting(0);
    this.controller = controller;
    I = this;
    controller.beginGame(this);
  }
  
  public function tick():Void {
    controller.tick(this);
  }
}

enum GameState {
  Starting(t:Int);
  StartingTurn(p:Player);
  PlayerTurn(p:Player, timer:Int);
  FinishingTurn(p:Player);
  GameOver(winner:Null<Player>);
}
