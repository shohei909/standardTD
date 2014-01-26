package standardTD.logic.battle;
import haxe.CallStack;
import haxe.web.Dispatch.DispatchRule;
import standardTD.logic.battle.enemy.TDBattleEnemyInitialData.TDBattleEnemyResourceData;
import standardTD.logic.battle.log.TDBattleLog;
import standardTD.master.TDBattleMasterData;
import standardTD.debug.DebugTools;
import standardTD.logic.battle.enemy.TDBattleWaveState;
import standardTD.logic.battle.error.TDBattleError;
import standardTD.logic.battle.TDBattleEvent;
import standardTD.logic.battle.error.TDBattleError;
import standardTD.logic.battle.tower.TDBattleTower;
import standardTD.logic.battle.log.TDBattleCommand;
import standardTD.logic.battle.log.TDBattleInitialData;
import standardTD.logic.battle.tower.TDBattleCell;
import standardTD.logic.battle.enemy.TDBattleEnemy;
import common.Random;

/**
 * ...
 * @author shohei909
 */
class TDBattle {
	static public inline var SKIP_BONUS_RATE:Float = 0.1;
	static public inline var COMMAND_LIMIT:Int = 1;
	static public inline var ENEMY_INTERVAL:Int = 20;
	static public inline var START_X:Int = 3;
	static public inline var START_Y:Int = 0;
	static public inline var WIDTH:Int = 10;
	static public inline var HEIGHT:Int = 12;
	
	public var field(default,null):Array<Array<TDBattleCell>>;
	public var enemys(default,null):Array<TDBattleEnemy>;
	public var frame(default, null):Int = 0;
	public var random(default, null):Random;
	public var waveIndex(default, null):Int;
	public var waveFrame(default, null):Int;
	public var waveState(default, null):TDBattleWaveState;
	public var waves:Array<TDBattleWaveData>;
	public var towers(default, null):Map<Int,TDBattleTower>;
	public var towerResource:Array<TDBattleTowerResourceData>;
	public var enemyResource:Array<TDBattleEnemyResourceData>;
	public var currentEvents(default, null):Array<TDBattleEvent>;
	public var castle(default, null):TDBattleTower;
	public var finished(default, null):Bool;
	public var money(default, null):Int;
	var towerIndex:Int = 0;
	var commandLog:Map<Int,Array<TDBattleCommand>>;
	var battleId:Int = 0;
	var initialData:TDBattleInitialData;
	var fieldChanged:Bool;
	var commands:Array<TDBattleCommand>;
	
	public function new( initialData:TDBattleInitialData ) {
		field = [];
		commands = [];
		currentEvents = [];
		random = new Random( initialData.randomSeed );
		this.initialData = initialData;
		this.towerResource = initialData.towerResourceData;
		this.enemyResource = initialData.enemyResourceData;
		
		var index = 0;
		for ( resource in towerResource ) {
			resource.index = index++;
		}
		index = 0;
		for ( resouce in enemyResource ) {
			resouce.index = index++;
		}
		
		for ( i in 0...HEIGHT ) {
			field[i] = [];
			for ( j in 0...WIDTH ) {
				field[i][j] = new TDBattleCell(j,i);
			}
		}
		
		finished = false;
		
		enemys = [];
		commandLog = new Map<Int,Array<TDBattleCommand>>();
		towers = new Map<Int,TDBattleTower>();
		
		for ( data in initialData.towers ) {
			var resource = initialData.towerResourceData[ data.index ];
			addTower( new TDBattleTower( this, data.level, resource ), data.x, data.y );
		}
		
		fieldChanged = true;
		money = initialData.money;
		waves = initialData.waves;
		
		if ( waves == null || initialData.waves.length == 0 )
			throw TDBattleError.FATAL( "missing waves" );
			
		waveIndex = 0;
		waveFrame = 0;
		waveState = TDBattleWaveState.INTERVAL( waves[0].interval );
	}
	
	public function addCommand( command:TDBattleCommand ):Bool {
		if ( finished ) return false;
		if ( commands.length >= COMMAND_LIMIT ) return false;
		
		commands.push( command );
		return true;
	}
	
	public function progress():Iterable<TDBattleEvent> {
		currentEvents = [];
		if ( finished ) return currentEvents;
		
		//play commands
		{
			var i = 0;
			for ( command in commands ) {
				if( i++ < COMMAND_LIMIT ) {
					playCommand( command );
				} else {
					currentEvents.push( REJECT_COMMAND( command, "too many command" ) );
				}
			}
		}
		commands = [];
			
		//calcuration
		if ( fieldChanged ) {
			calcRoute();
			fieldChanged = false;
		}
		
		for ( enemy in enemys ) {
			enemy.progress();
		}
		
		for( tower in towers )
			tower.progress();
		
		var currentState:TDBattleWaveState;
		
		while( true ) {
			currentState = waveState;
			
			switch( waveState ) {
				case INTERVAL( interval ):
					if ( interval <= waveFrame ) {
						finishWaveInterval();
					}
					
				case ATTACK( index, length ):
					if ( length <= waveFrame ){
						progressWaveAttack( index );
					}
					
				case FINISHED : 
					if ( enemys.length == 0 ) {
						win();
					}
			}
			
			//waveに変更がなければループを抜ける。
			if ( currentState == waveState ) break;
		}
		
		waveFrame++;
		frame++;
		
		return currentEvents;
	}
	
	function finishWaveInterval() {
		waveFrame = 0;
		waveState = TDBattleWaveState.ATTACK( 0, ENEMY_INTERVAL );
	}
	
	function progressWaveAttack( enemyIndex:Int ) {
		waveFrame = 0;
		addEnemy( waves[waveIndex].enemys[ enemyIndex ] );
		
		enemyIndex++;
		var wave = waves[ waveIndex ];
		var enemyLength = enemyIndex;
		
		if ( wave.enemys.length <= enemyIndex ) {
			waveIndex++;
			if ( waves.length <= waveIndex ) {
				waveState = TDBattleWaveState.FINISHED;
			}else {
				waveState = TDBattleWaveState.INTERVAL( waves[waveIndex].interval );
			}
		}else {
			waveState = TDBattleWaveState.ATTACK( enemyIndex, ENEMY_INTERVAL );
		}
	}
	
	function addEnemy( enemyResourceIndex:Int ) {
		var resource = enemyResource[ enemyResourceIndex ];
		var enemy = new TDBattleEnemy( this, resource, START_X, START_Y );
	}
	
	function playCommand( command:TDBattleCommand ) {
		try{
			switch( command ){
				case BUILD( tower, x, y ): 
					build( tower, x, y );
					
				case MOVE( id, tx, ty ): 
					move( id, tx, ty );
					
				case SKIP: 
					skip();
			}
		}catch( e:TDBattleError ){
			switch( e ) {
				case TDBattleError.REJECT( message ):
					DebugTools.error( message, CallStack.exceptionStack() );
					currentEvents.push( TDBattleEvent.REJECT_COMMAND( command, message ) );
					
				case TDBattleError.FATAL( message ):
					DebugTools.error( message, CallStack.exceptionStack() );
					throw message;
			}
			return false;
		}
		
		var arr = commandLog[ frame ];
		if ( arr == null ) 
			arr = commandLog[ frame ] = [];
			
		arr.push( command );
		
		return true;
	}
	
	function skip() {
		switch( waveState ) {
			case TDBattleWaveState.INTERVAL( interval ): 
				var skipFrame = interval - waveFrame;
				addMoney( Std.int( skipFrame * SKIP_BONUS_RATE ) );
				finishWaveInterval();
				
			case TDBattleWaveState.ATTACK(_, _),
				TDBattleWaveState.FINISHED:
				throw TDBattleError.REJECT( "can't skip." );
		}
	}
	
	public function addMoney( value:Int ) {
		money += value;
		currentEvents.push( TDBattleEvent.ADD_MONEY( value ) );
	}
	
	function build( towerResourceId:Int, x:Int, y:Int ) {
		var resource:TDBattleTowerResourceData = initialData.towerResourceData[towerResourceId];
		
		if ( resource == null )
			throw TDBattleError.REJECT( "no such resource of tower." );
			
		var levelData = resource.levelData;
		if ( levelData == null || levelData.length == 0 )
			throw TDBattleError.FATAL( "invaild resource of tower." );
			
		var cost = levelData[0].cost;
		if ( money < cost )
			throw TDBattleError.REJECT( "not enough money." );
			
		money -= cost;
		var tower = new TDBattleTower( this, 0, resource );
		addTower( tower, x, y );
		fieldChanged = true;
	}
	
	function addTower( tower:TDBattleTower, x:Int, y:Int ) {
		simpleMovableCheck( tower, x, y );
		
		//add
		var resource = tower.resource;
		for ( i in y...(y + resource.height) ) {
			for ( j in x...(x + resource.width) ) {
				var cell:TDBattleCell = field[i][j];
				cell.tower = tower;
			}
		}
		
		towers[ towerIndex ] = tower;
		tower.x = x;
		tower.y = y;
		tower.id = towerIndex;
		
		towerIndex++;
	}
	
	function move( towerId:Int, x:Int, y:Int ) {
		var tower = towers[ towerId ];
			
		if ( tower == null )
			throw TDBattleError.REJECT( "no such tower." );
			
		if (! tower.canMove )
			throw TDBattleError.REJECT( "can't move." );
			
		simpleMovableCheck( tower, x, y );
			
		//remove
		var resource = tower.resource;
		for ( i in tower.y...(tower.y + resource.height) ) {
			for ( j in tower.x...(tower.x + resource.width) ) {
				var cell:TDBattleCell = field[i][j];
				cell.tower = null;
			}
		}
		
		//add
		for ( i in y...(y + resource.height) ) {
			for ( j in x...(x + resource.width) ) {
				var cell:TDBattleCell = field[i][j];
				cell.tower = tower;
			}
		}
		
		tower.x = x;
		tower.y = y;
		fieldChanged = true;
	}
	
	function simpleMovableCheck( tower:TDBattleTower, x, y ){
		var resource = tower.resource;
			
		for ( i in y...(y + resource.height) ) {
			if ( i < 0 || HEIGHT <= i ) 
				throw TDBattleError.REJECT( "can't put here. out of field." );
			
			for ( j in x...(x + resource.width) ) {
				if ( j < 0 || WIDTH <= j ) 
					throw TDBattleError.REJECT( "can't put here. out of field." );
					
				var cell:TDBattleCell = field[i][j];
				if ( cell.tower != null && cell.tower != tower ) 
					throw TDBattleError.REJECT( "can't put here. already exist." );
					
				if ( cell.enemys.length > 0 ) 
					throw TDBattleError.REJECT( "can't put here. enemy exist." );
			}
		}
		
		if( tower.resource.isCastle ) {
			if( castle == null ){
				castle = tower;
			}else{
				throw TDBattleError.REJECT( "castle is already exist." );
			}
		}
	}
	
	function calcRoute() {
		calcGround( field, castle );
		
		var cell:TDBattleCell = field[START_Y][START_X];
		if ( cell.distanceFromcastle == 0x7FFFFFFF ) {
			throw TDBattleError.FATAL( "illegal route" );
		}
		
		for ( enemy in enemys ) {
			var cell:TDBattleCell = field[enemy.y][enemy.x];
			if ( cell.distanceFromcastle == 0x7FFFFFFF ) {
				throw TDBattleError.FATAL( "illegal route" );
			}
			
			enemy.updateNext();
		}
	}
	
	public function calcMovable( tower:TDBattleTower, x:Int, y:Int ) {
		var _field = copyField();
		
		var resource = tower.resource;
		for ( i in tower.y...(tower.y + resource.height) ) {
			for ( j in tower.x...(tower.x + resource.width) ) {
				var cell:TDBattleCell = _field[i][j];
				cell.tower = null;
			}
		}
		
		return _calcAddable( _field, tower, x, y );
	}
	
	public function calcAddable( tower:TDBattleTower, x:Int, y:Int ) {
		return _calcAddable( copyField(), tower, x, y );
	}
	
	function _calcAddable( _field:Array<Array<TDBattleCell>>, tower:TDBattleTower, x:Int, y:Int ) {
		
		//add
		var resource = tower.resource;
		for ( i in y...(y + resource.height) ) {
			if ( i < 0 || HEIGHT <= i ) 
				return "can't put here. out of field.";
			
			for ( j in x...(x + resource.width) ) {
				if ( j < 0 || WIDTH <= j ) 
					return "can't put here. out of field.";
					
				var cell:TDBattleCell = _field[i][j];
				if ( cell.tower != null ) 
					return "can't put here. already exist.";
					
				if ( cell.enemys.length > 0 ) 
					return "can't put here. enemy exist.";
					
				cell.tower = tower;
			}
		}
		
		return calcRouteAvailable( _field );
	}
	
	function calcRouteAvailable( _field:Array<Array<TDBattleCell>> ) {
		calcGround( _field, castle );
		
		var cell:TDBattleCell = _field[START_Y][START_X];
		if ( cell.distanceFromcastle == 0x7FFFFFFF ) {
			return "illegal route";
		}
		
		for ( enemy in enemys ) {
			var cell:TDBattleCell = _field[enemy.y][enemy.x];
			if ( cell.distanceFromcastle == 0x7FFFFFFF ) {
				return "illegal route";
			}
		}
		
		return null;
	}
	
	function copyField() {
		var copy = [];
		for ( i in 0...HEIGHT ) {
			copy[i] = [];
			for ( j in 0...WIDTH ) {
				copy[i][j] = field[i][j].shallowCopy();
			}
		}
		return copy;
	}
	
	static function calcGround( _field:Array<Array<TDBattleCell>>, castle:TDBattleTower ) {
		if ( castle == null )
			throw TDBattleError.FATAL( "castle must be exist." );
			
		for ( i in 0...HEIGHT ) {
			for ( j in 0...WIDTH ) {
				_field[i][j].distanceFromcastle = 0x7FFFFFFF;
			}
		}
		
		var cells = [];
		var cx = castle.x;
		var cy = castle.y;
		var castleResource = castle.resource;
		for ( i in cy...(cy + castleResource.height) ) {
			for ( j in cx...(cx + castleResource.width) ) {
				var cell = _field[i][j];
				cells.push( cell );
				cell.distanceFromcastle = 0;
			}
		}
		
		while ( cells.length > 0 ) {
			var nextCells = [];
			for ( cell in cells ) {
				var d = cell.distanceFromcastle + 1;
				var x = cell.x;
				var y = cell.y;
				if ( x < WIDTH - 1 ) {
					var neighber = _field[y][x + 1];
					if( neighber.distanceFromcastle > d && neighber.tower == null ){
						neighber.distanceFromcastle = d;
						nextCells.push( neighber );
					}
				}
				if ( 0 < x ) {
					var neighber = _field[y][x - 1];
					if( neighber.distanceFromcastle > d && neighber.tower == null ){
						neighber.distanceFromcastle = d;
						nextCells.push( neighber );
					}
				}
				if ( y < HEIGHT - 1 ) {
					var neighber = _field[y + 1][x];
					if( neighber.distanceFromcastle > d && neighber.tower == null ){
						neighber.distanceFromcastle = d;
						nextCells.push( neighber );
					}
				}
				if ( 0 < y ) {
					var neighber = _field[y - 1][x];
					if( neighber.distanceFromcastle > d && neighber.tower == null ){
						neighber.distanceFromcastle = d;
						nextCells.push( neighber );
					}
				}
			}
			
			cells = nextCells;
		}
	}
	
	public inline function containsPosition( x:Int, y:Int ) {
		return (0 <= x && x < WIDTH && 0 <= y && y < HEIGHT);
	}
	
	public function getLog():TDBattleLog {
		return {
			battleId : initialData.id, 
			commandLog : commandLog,
			frame : frame,
		};
	}
	
	public function lose( enemy:TDBattleEnemy ) {
		if ( finished ) return;
		
		currentEvents.push( TDBattleEvent.LOSE( enemy ) );
		finished = true;
	}
	
	public function win() {
		if ( finished ) return;
		
		currentEvents.push( TDBattleEvent.WIN );
		finished = true;
	}
}