package standardTD.logic.battle.tower;
import standardTD.logic.battle.enemy.TDBattleEnemy;
import standardTD.logic.battle.tower.TDBattleTower;

/**
 * ...
 * @author shohei909
 */

class TDBattleCell{
	public var tower:TDBattleTower;
	public var enemys:Array<TDBattleEnemy>;
	public var distanceFromcastle:Int;
	public var x:Int;
	public var y:Int;
	
	public function new( x:Int, y:Int ) {
		this.x = x;
		this.y = y;
		this.enemys =[];
	}
	
	public function shallowCopy() {
		var copy = new TDBattleCell( x, y );
		copy.enemys = this.enemys;
		copy.tower = this.tower;
		return copy;
	}
}