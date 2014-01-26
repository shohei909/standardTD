package standardTD.ui.battle.part.effect;
import flash.display.Bitmap;
import flash.display.Sprite;
import tweenx909.TweenX;

/**
 * ...
 * @author shohei909
 */
class TDBattleEffect extends Sprite {
	var startFrame:Float;
	var length:Float;
	public var depth:Float;
	public var finished:Bool = false;
	public var removeOnFinish = true;
	public var onFinish:Void->Void;
	
	public function new( startFrame:Float, length:Float ) {
		super();
		this.startFrame = startFrame;
		this.length = length;
		draw( 0 );
	}
	
	public function progress( currentFrame:Float ) {
		var frame = currentFrame - startFrame;
		if ( frame < length ) {
			draw( frame );
		} else {
			finished = true;
			
			if( onFinish != null )
				onFinish();
		}
	}
	
	public function draw( frame:Float ) {}
}