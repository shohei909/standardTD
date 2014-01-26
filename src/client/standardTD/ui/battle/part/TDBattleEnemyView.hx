package standardTD.ui.battle.part;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import openfl.Assets;
import standardTD.logic.battle.enemy.TDBattleEnemy;

/**
 * ...
 * @author shohei909
 */
class TDBattleEnemyView extends Bitmap {
	public var ANIMATION_SPEED = 0.25;
	
	public var enemy:TDBattleEnemy;
	public var resource:BitmapData;
	
	public function new (enemy:TDBattleEnemy) {
		this.enemy = enemy;
		resource = Assets.getBitmapData( 'img/enemy/${enemy.name}.png' );
		
		super( new BitmapData( Std.int(resource.width / 4), resource.height ) );
		var rect = bitmapData.rect;
		bitmapData.copyPixels( resource, rect, new Point(0,0) );
	}
	
	public function draw( currentFrame:Float ) {
		var rect = bitmapData.rect.clone();
		var w = rect.width;
		var frame = Std.int( currentFrame * ANIMATION_SPEED );
		rect.x = w * (frame % 2);
		bitmapData.copyPixels( resource, rect, new Point(0, 0) );
		
		var frame = currentFrame - enemy.lastMoveFrame;
		var motionRate = frame / enemy.speed;
		var ex, ey;
		
		if ( motionRate < 0 ) 		motionRate = 0;
		else if ( motionRate > 1 ) 	motionRate = 1;
		
		var r0 = motionRate;
		var r1 = 1 - r0;
		ex = enemy.prevX * r1 + enemy.x * r0;
		ey = enemy.prevY * r1 + enemy.y * r0;
		
		x = Math.round( ex * TDBattleFieldView.CELL_WIDTH );
		y = Math.round( (ey + 1) * TDBattleFieldView.CELL_HEIGHT - height );
	}
	
	public function getDepth() {
		return enemy.y - 0.5;
	}
}