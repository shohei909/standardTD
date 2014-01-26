package standardTD.ui.top;
import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import openfl.Assets;
import standardTD.ui.common.TDPage;
import standardTD.ui.common.TDPageType;

/**
 * ...
 * @author shohei909
 */

class TDTopPage extends TDPage {	
	public function new() {
		super();
		
		graphics.beginBitmapFill( Assets.getBitmapData( "img/ui/top/topBackground.png" ) );
		graphics.drawRect( 0, 0, Main.screenWidth, Main.screenHeight );
		
		var title = new Bitmap( Assets.getBitmapData( "img/ui/top/title.png" ) );
		title.y = 20;
		title.x = (Main.screenWidth - title.width) / 2;
		addChild( title );
		
		var image = new Bitmap( Assets.getBitmapData( "img/tower/castle.png" ) );
		image.y = (Main.screenHeight - image.height) / 2;
		image.x = (Main.screenWidth - image.width) / 2;
		addChild( image );
		
		var btnImage = new Bitmap( Assets.getBitmapData( "img/ui/top/startBtn.png" ) );
		var btn = new Sprite();
		btn.buttonMode = true;
		btn.addChild( btnImage );
		btn.y = Main.screenHeight - 30;
		btn.x = (Main.screenWidth - btn.width) / 2;
		addChild( btn );
		btn.addEventListener( MouseEvent.MOUSE_UP, onStartButton );
		
	}
	
	
	function onStartButton( e ) {
		Main.pageManager.transfer( TDPageType.BATTLE_PAGE, 0 );
	}
}