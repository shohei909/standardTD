package standardTD.logic.battle;
import standardTD.logic.battle.enemy.TDBattleEnemy;
import standardTD.logic.battle.log.TDBattleCommand;
import standardTD.logic.battle.TDBattleEvent.TDBattleEventTowerAttackType;
import standardTD.logic.battle.tower.equip.TDBattleEquipment;

enum TDBattleEvent {
	REJECT_COMMAND( command:TDBattleCommand, message:String );
	TOWER_ATTACK( equipment:TDBattleEquipment );
	ENEMY_DAMAGED( enemy:TDBattleEnemy, damage:Int, dead:Bool );
	ADD_MONEY( money:Int );
	WIN;
	LOSE( enemy:TDBattleEnemy );
}