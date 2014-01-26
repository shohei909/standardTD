package standardTD.logic.battle.enemy;
import standardTD.logic.battle.log.TDBattleInitialData.TDBattleEnemyResourceData;
import standardTD.logic.battle.TDBattle;
import standardTD.logic.battle.TDBattleEvent;
import standardTD.logic.battle.tower.TDBattleCell;

/**
 * ...
 * @author shohei909
 */
class TDBattleEnemy {
	static var DIR = [ 
		[1, 0], [-1, 0], [0, 1], [0, -1],
	];
	var battle:TDBattle;
	public var prevX:Int;
	public var prevY:Int;
	public var x:Int;
	public var y:Int;
	public var nextX:Int;
	public var nextY:Int;
	public var name:String;
	public var speed:Int;
	public var birthFrame:Int;
	public var lastMoveFrame:Int;
	public var currentLife:Int;
	public var money:Int;
	public var dead:Bool;
	
	public function new( battle:TDBattle, resource:TDBattleEnemyResourceData, x:Int, y:Int ) {
		prevX = x;
		prevY = y - 1;
		dead = false;
		this.x = x;
		this.y = y;
		this.name = resource.name;
		this.battle = battle;
		this.speed = resource.speed;
		this.currentLife = resource.life;
		this.money = resource.money;
		
		battle.enemys.push( this ); 
		battle.field[y][x].enemys.push( this );
		lastMoveFrame = birthFrame = battle.frame;
		updateNext();
	}
	
	public function progress() {
		var frame = battle.frame - birthFrame;
		if ( frame % speed == 0 ) {
			move();
		}
	}
	
	public function damage( value:Int ) {
		if ( dead ) return;
		currentLife -= value;
		if ( currentLife <= 0 ) {
			die();
		} else {
			battle.currentEvents.push( TDBattleEvent.ENEMY_DAMAGED( this, value, false ) );
		}
	}
	
	public function die() {
		if ( dead ) return;
		battle.currentEvents.push( TDBattleEvent.ENEMY_DAMAGED( this, currentLife, true ) );
		currentLife = 0;
		dead = true;
		battle.addMoney( money );
		remove();
	}
	
	function remove() {
		battle.field[y][x].enemys.remove( this );
		battle.enemys.remove( this );
	}
	
	public function move() {
		battle.field[y][x].enemys.remove( this );
		prevX = x;
		prevY = y;
		x = nextX;
		y = nextY;
		var nextCell = battle.field[y][x];
		nextCell.enemys.push( this );
		
		if( nextCell.tower == battle.castle ){
			battle.lose( this );
		}else {
			updateNext();
		}
		
		lastMoveFrame = battle.frame;
	}
	
	public function updateNext() {
		var max = 0x7FFFFFFF;
		var nextList = [];
		
		for ( d in DIR ) {
			var nx = x + d[0];
			var ny = y + d[1];
			
			if ( nx < 0 || TDBattle.WIDTH <= nx || ny < 0 || TDBattle.HEIGHT <= ny ) 
				continue;
				
			var cell:TDBattleCell = battle.field[ny][nx];
			if ( cell.tower != null && cell.tower != battle.castle ) continue;
			
			var distance = cell.distanceFromcastle;
			if ( distance == max ) {
				nextList.push( d );
			} else if( distance < max ){
				nextList = [ d ];
				max = distance;
			}
		}
		
		var length = nextList.length;
		if ( length == 0 ) {
			nextX = x;
			nextY = y;
			return;
		}
		
		var next = if ( length == 1 ) {
			nextList[0];
		}else {
			nextList[ battle.random.range(0, length) ];
		}
		
		nextX = x + next[0];
		nextY = y + next[1];
	}
}