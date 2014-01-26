package standardTD.ui.battle.part;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import openfl.Assets;
import standardTD.logic.battle.log.TDBattleInitialData.TDBattleTowerResourceData;
import standardTD.logic.battle.TDBattle;
import standardTD.logic.battle.tower.TDBattleTower;
import standardTD.ui.battle.part.TDBattleCursor.TDBattleCursorType;

/**
 * ...
 * @author shohei909
 */
class TDBattleTowerSelectView extends Sprite {
	static public var IMAGE_SPAN:Int = 1;
	static public var HEIGHT:Int = 18;
	static public var WIDTH:Int = TDBattleFieldView.CELL_WIDTH * 2;
	
	public var selectableTowerIndexes:Array<Int>;
	public var imageList:Array<TDBattleTowerView>;
	public var cursor:TDBattleCursor;
	public var selected(default, null):TDBattleTowerResourceData;
	var fieldView:TDBattleFieldView;
	var battle:TDBattle;
	var touchDown:Bool;
	
	public function new( battle:TDBattle ) {
		super();
		selectableTowerIndexes = [];
		imageList = [];
		this.battle = battle;
		
		var i = 0, j = 0;
		for ( resource in battle.towerResource ) {
			if ( resource.canBuy ) {
				selectableTowerIndexes.push( j );
				
				var image = new TDBattleTowerView( new TDBattleTower( null, 0, resource ) );
				imageList.push( image );
				addChild( image );
				image.x = (IMAGE_SPAN + WIDTH) * i;
				image.y = HEIGHT;
				i++;
			}
			j++;
		}
		
		cursor = new TDBattleCursor( TDBattleCursorType.SELECT );
		cursor.visible = false;
		cursor.alpha = 0.8;
		addChild( cursor );
		
		addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_DOWN, onTouchDown );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_UP, onTouchUp );
	}
	
	function onRemoved( e ) {
		removeEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		Lib.current.stage.removeEventListener( MouseEvent.MOUSE_DOWN, onTouchDown );
		Lib.current.stage.removeEventListener( MouseEvent.MOUSE_UP, onTouchUp );
	}
	
	function onTouchDown( e ) {
		if ( battle.finished ) return;
		var rect = new Rectangle( 0, 0, Main.screenWidth, HEIGHT );
		var p = globalToLocal( new Point( e.stageX, e.stageY ) );
		
		if( rect.containsPoint( p ) ){
			touchDown = true;
		}
	}
	
	function onTouchUp( e ) {
		if ( battle.finished ) return;
		if (! touchDown ) return;
		touchDown = false;
		
		var i:Int = 0;
		for ( image in imageList ) {
			if ( image.getRect( stage ).contains( e.stageX, e.stageY ) ) {
				select( i );
				return;
			}
			i++;
		}
		
		cancel();
	}
	
	public function update() {}
	
	public function select( index:Int ) {
		if ( battle.finished ) return;
		
		var selected = battle.towerResource[ selectableTowerIndexes[index] ];
		if ( this.selected == selected ) return;
		this.selected = selected;
		
		var image = imageList[index];
		cursor.x = image.x + (image.width - cursor.width) / 2;
		var h = TDBattleFieldView.CELL_HEIGHT * 2;
		cursor.y = image.y + (h - cursor.height) / 2 - h;
		cursor.visible = true;
		
		dispatchEvent( new Event( Event.SELECT ) );
	}
	
	public function cancel() {
		if ( selected == null ) return;
		selected = null;
		cursor.visible = false;
		dispatchEvent( new Event( Event.SELECT ) );
	}
}