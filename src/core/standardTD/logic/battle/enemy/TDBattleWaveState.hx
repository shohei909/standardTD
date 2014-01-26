package standardTD.logic.battle.enemy;

/**
 * ...
 * @author shohei909
 */
enum TDBattleWaveState {
	INTERVAL( length:Int );
	ATTACK( enemyIndex:Int, length:Int );
	FINISHED;
}