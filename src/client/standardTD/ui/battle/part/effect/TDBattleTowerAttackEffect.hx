package standardTD.ui.battle.part.effect;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import haxe.macro.Expr.Var;
import haxe.Resource;
import openfl.Assets;
import standardTD.logic.battle.tower.equip.TDBattleEquipment;
import standardTD.ui.battle.part.TDBattleEnemyView;
import standardTD.ui.battle.part.TDBattleFieldView;
import standardTD.ui.battle.part.TDBattleTowerView;
import tweenx909.EaseX;
import tweenx909.rule.TimelineX;
import tweenx909.TweenX;

/**
 * ...
 * @author shohei909
 */
class TDBattleTowerAttackEffect extends TDBattleEffect {
	var enemyX:Int;
	var enemyY:Int;
	var towerX:Int;
	var towerY:Int;
	var tween:TweenX;
	var fire:Bitmap;
	
	public static inline var PERTICLE_NUM:Int = 3;
	public static inline var LENGTH:Int = 2;
	public static inline var FIRE_WIDTH:Int = 7;
	public static inline var FIRE_HEIGHT:Int = 7;
	
	public function new( enemy:TDBattleEnemyView, tower:TDBattleTowerView, startFrame:Float ) {
		super( startFrame, 3 );
		
		var perticle = [];
		enemyX = Std.int( enemy.x + enemy.width  / 2 );
		enemyY = Std.int( enemy.y + enemy.height / 2 );
		towerX = Std.int( tower.x + tower.width  / 2 );
		towerY = Std.int( tower.y - tower.height / 2 );
		
		fire = new Bitmap( new BitmapData( FIRE_WIDTH, FIRE_HEIGHT, true, 0 ) );
		addChild( fire );
		fire.x = enemyX - fire.width  / 2;
		fire.y = enemyY - fire.height / 2;
		
		tween = TweenX.serial([
			TweenX.from( fire, { visible : true } ),
			TweenX.tweenFunc( setFire, [null], [new TimelineX([0, 1, 2, 3])], 2, EaseX.quartInOut ),
		]);
	}
	
	override public function draw(frame:Float) {
		if( tween != null )
			tween.goto( frame );
	}
	
	function setFire( value:Int ) {
		var b = fire.bitmapData;
		var rect = b.rect.clone();
		rect.x = FIRE_WIDTH * value;
		var source = Assets.getBitmapData( "img/effect/fire.png" );
		b.copyPixels( source, rect, new Point( 0, 0 ) );
	}
}