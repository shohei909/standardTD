package standardTD.ui.battle.part.effect;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import openfl.Assets;
import standardTD.logic.battle.tower.TDBattleTower;
import standardTD.ui.battle.part.effect.TDBattleEffect;
import tweenx909.rule.TimelineX;
import tweenx909.TweenX;

/**
 * ...
 * @author shohei909
 */
class TDBattleBitmapAnimation extends TDBattleEffect {
	var tween:TweenX;
	var image:Bitmap;
	var resource:BitmapData;
	var imageNum:Int;
	
	public function new( resource:BitmapData, imageNum:Int, startFrame:Float, time:Float, removeOnFinish:Bool ) {
		super( startFrame, time );
		
		this.resource = resource;
		this.imageNum = imageNum;
		
		var bitmapData = new BitmapData( Std.int(resource.width / imageNum), resource.height, true, 0 );
		addChild( this.image = new Bitmap( bitmapData ) );
		tween = TweenX.tweenFunc1( setImage, 0, imageNum, time );
		
		this.removeOnFinish = removeOnFinish;
		
		setImage( 0 );
	}
	
	override public function draw( frame:Float ) {
		if( tween != null )
			tween.goto( frame );
	}
	
	function setImage( value:Float ) {
		var num = Std.int( value );
		if ( num >= imageNum ) num = imageNum - 1;
		if ( num < 0 ) num = 0;
		
		var b = image.bitmapData;
		var rect = b.rect.clone();
		rect.x = b.width * num;
		b.copyPixels( resource, rect, new Point(0,0) );
	}
}