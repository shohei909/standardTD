package standardTD.logic.battle.tower;
import standardTD.logic.battle.log.TDBattleInitialData.TDBattleTowerData;
import standardTD.logic.battle.log.TDBattleInitialData.TDBattleTowerLevelData;
import standardTD.logic.battle.log.TDBattleInitialData.TDBattleTowerResourceData;
import standardTD.logic.battle.TDBattle;
import standardTD.logic.battle.tower.equip.TDBattleEquipment;
import standardTD.logic.battle.tower.equip.TDBattleSingleTargetWeapon;

/**
 * ...
 * @author shohei909
 */
class TDBattleTower {
	
	public var level(default, set):Int;
	public var x:Int;
	public var y:Int;
	
	public var height(get, never):Int;
	public var width(get, never):Int;
	public var name(get, never):String;
	
	function get_height() return resource.height;
	function get_width() return resource.width;
	function get_name() return resource.name;
	
	public var id:Int = -1;
	public var canMove(default, null):Bool;
	public var resource(default, null):TDBattleTowerResourceData;
	public var frame(default, null):Int;
	public var equipments(default, null):Array<TDBattleEquipment>;
	public var battle(default, null):TDBattle;
	
	public function new( battle:TDBattle, level:Int, resource:TDBattleTowerResourceData ) {
		this.battle = battle;
		this.resource = resource;
		this.canMove = resource.canBuy;
		set_level( level );
		frame = 0;
	}
	
	function set_level( level:Int ) {
		equipments = [];
		for( eq in resource.levelData[level].equipments ) {
			var data = switch( eq ) {
				case SINGLE_TARGET_WEAPON( name, interval, power, range ) :
					new TDBattleSingleTargetWeapon( this, name, interval, power, range );
			}
			
			equipments.push( data );
		}
		
		return this.level = level;
	}
	
	public function progress() {
		for ( eq in equipments ) {
			eq.progress( frame );
		}
		frame++;
	}
}