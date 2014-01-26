package standardTD.ui.battle.part;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import openfl.Assets;
import standardTD.logic.battle.enemy.TDBattleEnemy;
import standardTD.logic.battle.tower.equip.TDBattleEquipment;
import standardTD.logic.battle.tower.equip.TDBattleEquipmentData;
import standardTD.logic.battle.tower.TDBattleTower;
import standardTD.ui.battle.part.effect.TDBattleEquipmentAnimationType;

/**
 * ...
 * @author shohei909
 */
class TDBattleEquipmentView extends Bitmap {
	public static var REACTION_EFFECT_LENGTH:Float = 1
	;
	
	public var equipment:TDBattleEquipment;
	public var resource:BitmapData;
	public var animation:TDBattleEquipmentAnimationType;
	public var animationStartFrame:Float;
	public var animationLength:Float;
	public var directionX:Int;
	public var directionY:Int;
	
	static var DIR = [
		{ img:0, invert:false, dir:[0, 1] },
		{ img:1, invert:false, dir:[1, 1] },
		{ img:2, invert:false, dir:[1, 0] },
		{ img:3, invert:false, dir:[1, -1] },
		{ img:4, invert:false, dir:[0, -1] },
		{ img:3, invert:true, dir:[-1, -1] },
		{ img:2, invert:true, dir:[-1, 0] },
		{ img:1, invert:true, dir:[-1, 1] },
	];
	
	public function new ( equipment:TDBattleEquipment ) {
		this.equipment = equipment;
		animation = null;
		resource = Assets.getBitmapData( 'img/equipment/${equipment.name}.png' );
		super( new BitmapData( equipment.tower.width * TDBattleFieldView.CELL_WIDTH, resource.height, true, 0 ) ); 
		setDirection( 0, 1 );
	}
	
	public function setDirection( dx:Int, dy:Int ) {
		var tower = equipment.tower;
		var dir = Std.int(Math.atan2( dy, -dx ) / (2 * Math.PI) * 8 + 6.5) % 8;
		var data = DIR[dir];
		
		var rect = bitmapData.rect;
		bitmapData.fillRect( rect, 0 );
		
		var matrix = new Matrix();
		if( data.invert ){
			matrix.scale( -1, 1 );
			matrix.translate( Std.int(rect.width * (data.img + 1)), 0 );
		} else {
			matrix.translate( Std.int(-rect.width * data.img), 0 );
		}
		
		directionX = data.dir[0];
		directionY = data.dir[1];
		bitmapData.draw( resource, matrix );
	}
	
	public function stopAnimation() {
		animation = null;
		animationLength = 0;
		animationStartFrame = 0;
	}
	
	public function startAttackEffect( currentFrame:Float ) {
		animation = TDBattleEquipmentAnimationType.REACTION( -directionX, -directionY );
		animationLength = REACTION_EFFECT_LENGTH;
		animationStartFrame = currentFrame;
	}
	
}