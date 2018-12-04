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
  public static var I:Main;
  
  public function new() {
    I = this;
    super([
         Framerate(60)
        ,Optional(Window("", 1000, 600))
        ,Surface(500, 300, 1)
        ,Assets([
             Embed.getBitmap("game", "png/game.png")
            ,Embed.getBitmap(font.FontBasic3x9.ASSET_ID, "png/basic3x9.png")
            ,Embed.getBitmap(font.FontNS.ASSET_ID, "png/ns8x16.png")
            
            ,Embed.getSound("hit_bombardierant", "wav/hit_bombardierant.wav")
            ,Embed.getSound("hit_bull", "wav/hit_bull.wav")
            ,Embed.getSound("hit_bumblebee", "wav/hit_bumblebee.wav")
            ,Embed.getSound("hit_chamois", "wav/hit_chamois.wav")
            ,Embed.getSound("hit_default", "wav/hit_default.wav")
            ,Embed.getSound("hit_eagle", "wav/hit_eagle.wav")
            ,Embed.getSound("hit_frog", "wav/hit_frog.wav")
            ,Embed.getSound("hit_hog", "wav/hit_hog.wav")
            ,Embed.getSound("hit_medusa", "wav/hit_medusa.wav")
            ,Embed.getSound("hit_mosquito", "wav/hit_mosquito.wav")
            ,Embed.getSound("hit_octopus", "wav/hit_octopus.wav")
            ,Embed.getSound("hit_snake", "wav/hit_snake.wav")
            ,Embed.getSound("hit_spider", "wav/hit_spider.wav")
            ,Embed.getSound("hit_squid", "wav/hit_squid.wav")
            ,Embed.getSound("hit_swordfish", "wav/hit_swordfish.wav")
            ,Embed.getSound("hit_wolf", "wav/hit_wolf.wav")
            ,Embed.getSound("repair", "wav/repair.wav")
            
            ,new AssetBind([
              "hit_bombardierant", "hit_bull", "hit_bumblebee", "hit_chamois", "hit_default", "hit_eagle", "hit_frog", "hit_hog", "hit_medusa", "hit_mosquito", "hit_octopus", "hit_snake", "hit_spider", "hit_squid", "hit_swordfish", "hit_wolf", "repair"
            ], (am, _) -> { Sfx.init(am); false; })
            
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
  
  public function st(to:String):Void {
    applyState(getStateById(to));
  }
}
