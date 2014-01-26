package standardTD.ui.battle.part;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.EnumTools.EnumValueTools;
import openfl.Assets;
import standardTD.ui.battle.part.TDBattleCursor.TDBattleCursorType;

/**
 * ...
 * @author shohei909
 */
class TDBattleCursor extends Bitmap {
	static public var WIDTH = TDBattleFieldView.CELL_WIDTH * 2 + 2;
	static public var HEIGHT = TDBattleFieldView.CELL_HEIGHT * 2 + 2;
	
	public function new( type:TDBattleCursorType ) {
		super( new BitmapData( WIDTH, HEIGHT, true ) );
		set_type( type );
	}
	
	public var type(default, set):TDBattleCursorType;
	
	function set_type( type:TDBattleCursorType ) {
		var index = EnumValueTools.getIndex( type );
		var rect = new Rectangle( WIDTH * index, 0, WIDTH, HEIGHT );
		var source = Assets.getBitmapData( "img/ui/battle/cursor.png" );
		
		bitmapData.copyPixels( source, rect, new Point(0,0) );
		return this.type = type;
	}
}

enum TDBattleCursorType {
	SELECT;
	TARGET;
	IMPOSSIBLE;
}