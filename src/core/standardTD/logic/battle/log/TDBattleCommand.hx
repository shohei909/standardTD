package standardTD.logic.battle.log;
import standardTD.logic.battle.tower.TDBattleTower;
import standardTD.logic.battle.log.TDBatttleCustomCommand;

enum TDBattleCommand {
	SKIP;
	BUILD( towerResourceId:Int, x:Int, y:Int );
	MOVE( towerId:Int, x:Int, y:Int );
}