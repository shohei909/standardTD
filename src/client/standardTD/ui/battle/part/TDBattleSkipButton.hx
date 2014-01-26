package standardTD.ui.battle.part;
import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import openfl.Assets;
import standardTD.logic.battle.enemy.TDBattleWaveState;
import standardTD.logic.battle.TDBattle;

/**
 * ...
 * @author shohei909
 */
class TDBattleSkipButton extends Sprite{
	var button:Bitmap;
	
	public function new() {
		super();
		
		var bitmapData = Assets.getBitmapData( "img/ui/battle/skipBtn.png" );
		button = new Bitmap( bitmapData );
		
		#if flash
		tabEnabled = false;
		#end
		
		addChild( button );
	}
	
	public function setState( state:TDBattleWaveState ) {
		switch( state ) {
			case TDBattleWaveState.INTERVAL(_):
				button.bitmapData = Assets.getBitmapData( "img/ui/battle/skipBtn.png" );
				buttonMode = mouseEnabled = true;
				
			default :
				button.bitmapData = Assets.getBitmapData( "img/ui/battle/skipBtnDisabled.png" );
				buttonMode = mouseEnabled = false;
		}
	}
}