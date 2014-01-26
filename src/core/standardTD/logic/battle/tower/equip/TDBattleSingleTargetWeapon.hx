package standardTD.logic.battle.tower.equip;
import standardTD.logic.battle.enemy.TDBattleEnemy;
import standardTD.logic.battle.TDBattle;
import standardTD.logic.battle.TDBattleEvent;
import standardTD.logic.battle.tower.equip.TDBattleEquipment;
import standardTD.logic.battle.tower.equip.TDBattleEquipmentData;
import standardTD.logic.battle.tower.TDBattleTower;

/**
 * ...
 * @author shohei909
 */
class TDBattleSingleTargetWeapon extends TDBattleEquipment {
	public var range:Int;
	public var power:Int;
	public var targetEnemy:TDBattleEnemy;
	
	public function new( tower:TDBattleTower, name:String, interval:Int, power:Int, range:Int ) {
		this.range = range;
		this.power = power;
		super( TDBattleEquipmentData.SINGLE_TARGET_WEAPON_DATA( this ), tower, name, interval );
	}
	
	override public function fire() {
		var top = tower.y;
		var left = tower.x;
		var right = tower.x + tower.resource.width - 1;
		var bottom = tower.y + tower.resource.height - 1;
		var range2 = range * range;
		targetEnemy = null;
		
		for ( enemy in tower.battle.enemys ) {
			if ( enemy.dead ) continue;
			
			var ex = enemy.x;
			var ey = enemy.y;
			
			var dx = 
				if ( ex < left ) 		left - ex;
				else if ( ex < right ) 	0;
				else 					ex - right;
				
			if ( dx > range ) 
				continue;
				
			var dy = 
				if ( ey < top ) 		top - ey;
				else if ( ey < bottom ) 0;
				else 					ey - bottom;
				
			if ( dx * dx + dy * dy > range2 ) 
				continue;
			
			tower.battle.currentEvents.push( TDBattleEvent.TOWER_ATTACK( this ) );
			targetEnemy = enemy;
			targetEnemy.damage( power );
			break;
		}
	}
}