package standardTD.master;
import standardTD.logic.battle.tower.equip.TDBattleEquipment;
import standardTD.logic.battle.tower.equip.TDBattleEquipmentType;
import standardTD.logic.battle.enemy.TDBattleEnemyActionType;
import standardTD.logic.battle.log.TDBattleInitialData;

/**
 * ダミーのデータ
 * @author shohei909
 */
class TDBattleMasterData {
	static public var getData = function ( id:String ) { 
		return data[ id ];
	};
	
	static public var data(default, null):Map<String, TDBattleInitialData> = [
		"0" => {
			id : "0",
			randomSeed : 4329,
			money : 30,
			life : 1,
			frameLimit : 5000,
			towerResourceData : [
				{
					name : "castle",
					canBuy : false,
					isCastle : true,
					width : 2,
					height : 2,
					levelData : [
						{
							cost : 0,
							equipments : [],
						}
					],
				},
				{
					name : "wall",
					canBuy : true,
					width : 2,
					height : 2,
					levelData : [
						{
							cost : 1,
							equipments : [],
						}
					],
				},
				{
					name : "cannon",
					canBuy :true,
					width : 2,
					height : 2,
					levelData : [
						{
							cost : 10,
							equipments : [
								TDBattleEquipmentType.SINGLE_TARGET_WEAPON( "lightCannon", 8, 1, 2 ),
							],
						},
						{
							cost : 20,
							equipments : [
								TDBattleEquipmentType.SINGLE_TARGET_WEAPON( "lightCannon", 6, 2, 3 ),
							],
						},
						{
							cost : 40,
							equipments : [
								TDBattleEquipmentType.SINGLE_TARGET_WEAPON( "lightCannon", 4, 3, 4 ),
							],
						},
						{
							cost : 80,
							equipments : [
								TDBattleEquipmentType.SINGLE_TARGET_WEAPON( "lightCannon", 2, 4, 5 ),
							],
						},
						{
							cost : 160,
							equipments : [
								TDBattleEquipmentType.SINGLE_TARGET_WEAPON( "lightCannon", 2, 8, 6 ),
							],
						},
					],
				},
			],
			
			enemyResourceData : [
				{
					name : "monoEye",
					speed : 10,
					life : 10,
					money : 2,
					actionType : TDBattleEnemyActionType.WALK_TO_CASTLE,
				},
				{
					name : "mouse",
					speed : 5,
					life : 20,
					money : 5,
					actionType : TDBattleEnemyActionType.WALK_TO_CASTLE,
				}
			],
			
			waves : [
				{
					interval : 80,
					enemys : [0],
				},{
					interval : 80,
					enemys : [0,0],
				},{
					interval : 80,
					enemys : [0,0,0],
				},{
					interval : 80,
					enemys : [0,0,0,0,0],
				},{
					interval : 80,
					enemys : [0,1,1,1,1],
				},{
					interval : 80,
					enemys : [1,1,1,1,1],
				},{
					interval : 80,
					enemys : [1,1,1,1,1],
				},
			],
			
			towers : [
				{
					index : 0,
					level : 0,
					x : 4, 
					y : 10,
				}
			],
		}
	];
}