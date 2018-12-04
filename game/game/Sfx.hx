package game;

import sk.thenet.app.AssetManager;

using StringTools;

class Sfx {
  static var am:AssetManager;
  
  //static var music:Map<String, Crossfade>;
  public static var currentMusic:String = "ActuallyGood";
  public static var music = [
       "ActuallyGood"
      ,"Angelic"
      ,"Final"
      ,"Idk_kev"
      ,"Sneaky"
    ];
  public static var victoryMusic = [
       "Victory3"
      ,"Victory4"
      ,"VictoryFaction2"
      ,"VictoryQuestionMark"
    ];
  public static var musicChannel:sk.thenet.plat.js.common.audio.Sound.Channel;
  
  public static function isMusic(s:String):Bool {
    return s.startsWith("theme");
  }
  
  public static function init(am):Void {
    Sfx.am = am;
  }
  
  public static function initMusic():Void {
    //if (music == null) music = [
    //   "theme-boss1" => new Crossfade("theme-boss1")
    //  ,"theme-boss2" => new Crossfade("theme-boss2")
    //  ,"theme-calm" => new Crossfade("theme-calm")
    //  ,"theme-medium" => new Crossfade("theme-medium")
    //  ,"theme-action" => new Crossfade("theme-action")
    //];
  }
  
  public static function play3D(s:String, dx:Int, dy:Int, ?minDist:Int = 160):Void {
    var dist = dx.absI() + dy.absI();
    if (dist >= minDist) return;
    var vol = 1 - dist / minDist;
    var channel = play(s, vol);
    channel.setPan(dx / minDist);
  }
  
  public static function play(s:String, ?volume:Float = 1, ?forever:Bool = false) {
    var m = isMusic(s);
    var shouldPlay = m ? GSGame.musicOn : GSGame.soundOn;
    return am.getSound(s).play(forever ? Forever : Once, shouldPlay ? volume : 0);
  }
  
  static function shuffle():String {
    var c = music.copy();
    c.remove(currentMusic);
    return c[Std.random(c.length)];
  }
  
  public static function fanfare():Void {
    startMusic(victoryMusic[Std.random(victoryMusic.length)]);
  }
  
  public static function startMusic(?choice:String):Void {
    currentMusic = choice != null ? choice : shuffle();
    if (musicChannel != null) musicChannel.stop();
    musicChannel = (cast play("music_" + currentMusic));
    musicChannel.setVolume(GSGame.musicOn ? 1 : 0);
  }
  
  public static function tick():Void {
    musicChannel.setVolume(GSGame.musicOn ? 1 : 0);
    if (!musicChannel.playing) {
      startMusic();
    }
    //if (music != null) for (k in music.keys()) music[k].tick(currentMusic == k);
  }
}
