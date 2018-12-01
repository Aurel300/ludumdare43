package game;

class GSGame extends JamState {
  public function new(app) {
    super("game", app);
    var g = new Game(new Map(null), [], null);
    var u = new Unit();
  }
}
