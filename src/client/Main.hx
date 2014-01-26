
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import common.Random;
import flash.ui.Mouse;
import standardTD.ui.battle.TDBattlePage;
import standardTD.save.TDLocalSaveUtil;
import standardTD.ui.common.TDPageManager;
import standardTD.ui.common.TDPageType;
import tweenx909.TweenX;

class Main extends Sprite {
	static public inline var screenWidth:Int = 80;
	static public var screenHeight(default, null):Int;
	static public var frameRate(default, null):Int;
	static public var currentFrame(default, null):Int = 0;
	static public var random(default, null):Random;
	static public var pageManager:TDPageManager;
	
	static var touching:Bool = false;
	static var events:Array<MouseEvent>;
	
	static public function main() {
		var current:Sprite = Lib.current;
		var stage:Stage = Lib.current.stage;
		frameRate = Std.int( stage.frameRate );
		setupSize();
		
		TweenX.defaultAutoPlay = false;
		TDLocalSaveUtil.load();
		
		
		pageManager = new TDPageManager( current );
		pageManager.transfer( TDPageType.TOP_PAGE, 0 );
		
		stage.addEventListener( Event.ENTER_FRAME, onFrame );
		stage.addEventListener( Event.RESIZE, onResize );
		stage.addEventListener( MouseEvent.MOUSE_UP, onEvent );
		stage.addEventListener( MouseEvent.MOUSE_DOWN, onEvent );
		
		events = [];
	}
	
	static function onFrame( e ) {
		pageManager.update();
		
		events = [];
		currentFrame++;
	}
	
	static function onResize( e ) {
		setupSize();
		pageManager.resize();
	}
	
	static function setupSize() {
		var current:Sprite = Lib.current;
		var stage:Stage = Lib.current.stage;
		var scale:Float = stage.stageWidth / screenWidth;
		current.scaleX = current.scaleY = scale;
		screenHeight = Std.int( stage.stageHeight / scale );
	}
	
	static function onEvent( e:MouseEvent ) {
		trace( e );
	}
}
