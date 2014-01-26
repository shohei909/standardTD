package standardTD.ui.common;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;

/**
 * ...
 * @author shohei909
 */
class TDMoneyLabel extends Bitmap{
	var resource:BitmapData;
	var value:Int;
	static inline var NUM_WIDTH:Int = 5;
	static inline var NUM_HEIGHT:Int = 7;
	
	public function new( digit:Int ) {
		resource = Assets.getBitmapData( "img/ui/common/moneyLabel.png" );
		super( new BitmapData( digit * (NUM_WIDTH + 1), NUM_HEIGHT, true, 0 ) );
		setNumber( 0 );
	}
	
	public function setNumber( value:Int ) {
		this.value = value;
		bitmapData.fillRect( bitmapData.rect, 0 );
		
		var i:Int = 0;
		while ( value > 0 ) {
			drawNum( value % 10, i );
			value = Std.int( value / 10 );
			i++;
		}
		
		if ( i == 0 ) {
			drawNum( 0, 0 );
			i++;
		}
		
		drawNum( 10, i );
	}
	
	inline function drawNum( num:Int, pos:Int ) {
		var rect = new Rectangle( num * NUM_WIDTH, 0, NUM_WIDTH, NUM_HEIGHT );
		bitmapData.copyPixels( resource, rect, new Point( bitmapData.width - (pos + 1) * (NUM_WIDTH + 1), 0) );
	}
}