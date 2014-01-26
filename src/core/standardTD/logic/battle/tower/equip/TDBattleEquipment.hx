package standardTD.logic.battle.tower.equip;
import standardTD.logic.battle.TDBattle;
import standardTD.logic.battle.tower.equip.TDBattleEquipmentData;
import standardTD.logic.battle.tower.TDBattleTower;

/**
 * ...
 * @author shohei909
 */
class TDBattleEquipment {
	public var name:String;
	public var detail:TDBattleEquipmentData;
	public var tower:TDBattleTower;
	public var interval:Int;
	public var directionX:Int;
	public var directionY:Int;
	
	public function new( detail:TDBattleEquipmentData, tower:TDBattleTower, name:String, interval:Int ) {
		this.detail = detail;
		this.tower = tower;
		this.interval = interval;
		this.name = name;
		
		if ( Type.enumParameters( detail )[0] != this ) {
			throw "must be this object.";
		}
	}
	
	public function progress( currentFrame:Int ) {
		if ( interval < 0 ) return;
		if ( currentFrame % interval == 0 ) {
			fire();
		}
	}
	
	public function fire() {}
}