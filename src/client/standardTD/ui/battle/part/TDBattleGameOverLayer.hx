package standardTD.ui.battle.part;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxe.Serializer;
import openfl.Assets;
import standardTD.logic.battle.TDBattle;
import standardTD.sound.TDSound;
import standardTD.ui.battle.TDBattlePage;
import standardTD.ui.common.TDPageType;
import tweenx909.TweenX;

/**
 * ...
 * @author shohei909
 */
class TDBattleGameOverLayer extends Sprite {
	var title:Bitmap;
	var textField:TextField;
	var battle:TDBattle;
	
	public function new( battle:TDBattle ) {
		super();
		this.battle = battle;
		
		var background = new Sprite();
		background.graphics.beginFill( 0, 0.5 );
		background.graphics.drawRect( 0, 0, Main.screenWidth, Main.screenHeight );
		background.addEventListener( MouseEvent.CLICK, onAction );
		addChild( background );
		
		title = new Bitmap();
		addChild(title);
		
		var w = 50, h = 40;
		
		var textLayer = new Sprite();
		textField = new TextField();
		textField.width = w;
		textField.height = h;
		
		textLayer.addChild( textField );
		
		textLayer.x = (Main.screenWidth - w) / 2;
		textLayer.y = (Main.screenHeight - h - 15) / 2;
		
		textLayer.graphics.lineStyle( 1, 0, 1 );
		textLayer.graphics.beginFill( 0xFFFFFF, 0.8 );
		textLayer.graphics.drawRect( 0, 0, w, h );
		
		addChild( textLayer );
		
		textField.defaultTextFormat = new TextFormat( "_sans", 3.5, 0 );
		textField.multiline = true;
		textField.wordWrap = true;
		
		visible = false;
	}
	
	public function show( clear:Bool ) {
		if ( clear ){
			title.bitmapData = Assets.getBitmapData( "img/ui/battle/gameClearText.png" );
			TDSound.play( "fanfare" );
		}else{
			title.bitmapData = Assets.getBitmapData( "img/ui/battle/gameOverText.png" );
			//TDSound.play( "loss" );
		}
		
		title.y = 20;
		title.x = (Main.screenWidth - title.width) / 2;
		visible = true;
		
		textField.text = Serializer.run( battle.getLog() );
	}
	
	public function onAction( e ) {
		Main.pageManager.transfer( TDPageType.TOP_PAGE, 0 );
	}
}