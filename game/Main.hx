import sk.thenet.app.*;
import sk.thenet.app.TNPreloader;
import sk.thenet.app.asset.Bind as AssetBind;
import sk.thenet.app.asset.Bitmap as AssetBitmap;
import sk.thenet.app.asset.Sound as AssetSound;
import sk.thenet.app.asset.Trigger as AssetTrigger;
import sk.thenet.bmp.*;
import sk.thenet.plat.Platform;

import game.*;

using sk.thenet.FM;
using sk.thenet.stream.Stream;

class Main extends Application {
  public function new() {
    super([
         Framerate(60)
        ,Optional(Window("", 1000, 600))
        ,Surface(500, 300, 1)
        ,Assets([
          ])
        ,Keyboard
        ,Mouse
      ]);
    preloader = new TNPreloader(this, "game");
    addState(new GSGame(this));
    mainLoop();
  }
}
