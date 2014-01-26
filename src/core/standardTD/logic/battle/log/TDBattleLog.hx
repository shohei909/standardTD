package standardTD.logic.battle.log;

typedef TDBattleLog = {
	var battleId:String;
	var commandLog:Map<Int,Array<TDBattleCommand>>;
	var frame:Int;
}