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
             Embed.getBitmap("game", "png/game.png")
            ,Embed.getBitmap(font.FontBasic3x9.ASSET_ID, "png/basic3x9.png")
            ,Embed.getBitmap(font.FontNS.ASSET_ID, "png/ns8x16.png")
            ,new AssetTrigger("gameA", ["game"], (am, _) -> { GSGame.load(am.getBitmap); false; })
            ,new AssetTrigger("text", [font.FontBasic3x9.ASSET_ID, /*font.FontFancy8x13.ASSET_ID, */font.FontNS.ASSET_ID, "gameA"], (am, _) -> {
              Text.load(am);
              consoleFont = Text.fonts[0];
              false;
            })
            ,new AssetBind(["text"], (_, _) -> { UI.load(); false; })
          ])
        ,Keyboard
        ,Mouse
      ]);
    preloader = new TNPreloader(this, "game", true);
    addState(new GSGame(this));
    addState(new GSEditor(this));
    mainLoop();
  }
}
