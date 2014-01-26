package standardTD.logic.battle.log;
import standardTD.logic.battle.enemy.TDBattleEnemyActionType;
import standardTD.logic.battle.tower.equip.TDBattleEquipmentType;


typedef TDBattleInitialData = { 
	id : String,
	randomSeed : Int, 
	towerResourceData : Array<TDBattleTowerResourceData>,
	enemyResourceData : Array<TDBattleEnemyResourceData>,
	towers : Array<TDBattleTowerData>,
	waves : Array<TDBattleWaveData>,
	money : Int,
	life : Int,
	frameLimit : Int,
}

typedef TDBattleTowerResourceData = {
	name : String,
	canBuy : Bool,
	width : Int,
	height : Int,
	levelData : Array<TDBattleTowerLevelData>,
	?isCastle : Bool,
	?index : Int,
};

typedef TDBattleTowerLevelData = {
	cost : Int,
	equipments : Array<TDBattleEquipmentType>,
}

typedef TDBattleEnemyResourceData = {
	name : String,
	speed : Int, 
	life : Int,
	money : Int,
	actionType : TDBattleEnemyActionType,
	?index:Int,
};

typedef TDBattleWaveData = {
	interval : Int,
	enemys : Array<Int>,
};

typedef TDBattleTowerData = {
	index : Int,
	level : Int,
	x : Int,
	y : Int,
};