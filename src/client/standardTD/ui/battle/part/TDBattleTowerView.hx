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
class TDBattleTowerView extends Sprite {
	public var tower:TDBattleTower;
	public var background:Bitmap;
	public var equipments:Map<TDBattleEquipment,TDBattleEquipmentView>;
	public var resource:BitmapData;
	
	public function new (tower:TDBattleTower) {
		this.tower = tower;
		super();
		background = new Bitmap( Assets.getBitmapData( 'img/tower/${tower.name}.png' ) );
		background.y = -background.height;
		addChild( background );
		
		equipments = new Map<TDBattleEquipment,TDBattleEquipmentView>();
		for ( eq in tower.equipments ) {
			var view = new TDBattleEquipmentView( eq );
			view.y = - view.height;
			equipments[ eq ] = view;
			addChild( view );
		}
	}
	
	public function update() {
		for( view in equipments.iterator() ) {
			switch ( view.equipment.detail ) {
				case SINGLE_TARGET_WEAPON_DATA( weapon ):
					var enemy = weapon.targetEnemy;
					if( enemy != null ){
						var dx = (enemy.x - tower.x) * 2 - tower.width + 1;
						var dy = (enemy.y - tower.y) * 2 - tower.height + 1;
						view.setDirection(dx, dy);
					}
			}
		}
	}
	
	public function draw( currentFrame:Float ) {
		for ( view in equipments.iterator() ) {			
			if ( view.animation != null ) {
				var frame = currentFrame - view.animationStartFrame;
				
				if (frame >= view.animationLength) {
					view.x = 0;
					view.y = -view.height;
					view.stopAnimation();
				} else {
					switch( view.animation ) {
						case TDBattleEquipmentAnimationType.REACTION( moveX, moveY ):
							view.x = moveX;
							view.y = moveY - view.height;
					}
				}
			}
		}
	}
	
	public function startAttackEffect( equipment:TDBattleEquipment, currentFrame:Float ) {
		var view = equipments[ equipment ];
		view.startAttackEffect( currentFrame );
	}
	
	public function getDepth():Float {
		return (tower.y + tower.height - 1);
	}
}