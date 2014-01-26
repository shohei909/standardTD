package standardTD.ui.battle.part;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import openfl.Assets;
import standardTD.logic.battle.enemy.TDBattleEnemy;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import standardTD.logic.battle.log.TDBattleCommand;
import standardTD.logic.battle.log.TDBattleInitialData.TDBattleTowerResourceData;
import standardTD.logic.battle.TDBattle;
import standardTD.logic.battle.TDBattleEvent;
import standardTD.logic.battle.tower.equip.TDBattleEquipment;
import standardTD.logic.battle.tower.equip.TDBattleEquipmentData;
import standardTD.logic.battle.tower.TDBattleCell;
import standardTD.logic.battle.tower.TDBattleTower;
import standardTD.sound.TDSound;
import standardTD.ui.battle.part.effect.TDBattleBitmapAnimation;
import standardTD.ui.battle.part.effect.TDBattleEffect;
import standardTD.ui.battle.part.effect.TDBattleTowerAttackEffect;
import standardTD.ui.battle.part.TDBattleCursor;
import standardTD.ui.battle.part.TDBattleFieldView;
import standardTD.ui.battle.TDBattlePage;
import standardTD.ui.common.TDPage;

/**
 * ...
 * @author shohei909
 */
class TDBattleFieldView extends Sprite {
	static public inline var EXPLODE_WIDTH = 32;
	static public inline var EXPLODE_HEIGHT = 40;
	static public inline var EXPLODE_LEFT = 8;
	static public inline var EXPLODE_BOTTOM = 35;
	
	static public inline var CELL_WIDTH:Int = 8;
	static public inline var CELL_HEIGHT:Int = 7;
	static public inline var DROP_HEIGHT:Int = 2;
	
	static public inline var WIDTH:Int = CELL_WIDTH * TDBattle.WIDTH;
	static public inline var HEIGHT:Int = CELL_HEIGHT * TDBattle.HEIGHT;
	static public inline var EVENT_SELECT_TOWER:String = "selectTower";
	
	var towerSelectView:TDBattleTowerSelectView;
	var bitmapData:BitmapData;
	var battle:TDBattle;
	
	var towerViewMap:Map<TDBattleTower,TDBattleTowerView>;
	var enemyViewMap:Map<TDBattleEnemy,TDBattleEnemyView>;
	var effects:Array<TDBattleEffect>;
	var selectedTowerView:TDBattleTowerView;
	
	var fieldLayer:Sprite;
	var editLayer:Sprite;
	
	var editTowerView:TDBattleTowerView;
	var targetCursor:TDBattleCursor;
	var selectCursor:TDBattleCursor;
	var touchDown:Bool = false;
	
	var justSelected:Bool;
	var selectState:TDBattleFieldSelectState;
	var previewState:TDBattleFieldPreviewState;
	
 	public function new( battle:TDBattle, towerSelectView:TDBattleTowerSelectView ) {
		super();
		this.battle = battle;
		this.towerSelectView = towerSelectView;
		
		addChild( fieldLayer = new Sprite() );
		addChild( selectCursor = new TDBattleCursor( TDBattleCursorType.SELECT ) );
		addChild( editLayer = new Sprite() );
		addChild( targetCursor = new TDBattleCursor( TDBattleCursorType.TARGET ) );
		selectCursor.visible = false;
		targetCursor.visible = false;
		
		towerViewMap = new Map<TDBattleTower,TDBattleTowerView>();
		enemyViewMap = new Map<TDBattleEnemy,TDBattleEnemyView>();
		effects = [];
		update();
		
		towerSelectView.addEventListener( Event.SELECT, onSelectBuildTower );
		addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		addEventListener( MouseEvent.MOUSE_DOWN, onTouchDown );
		addEventListener( MouseEvent.MOUSE_MOVE, onTouchMove );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_UP, onTouchUp );
		
		graphics.beginFill( 0, 0 );
		graphics.drawRect( 0, 0, WIDTH, HEIGHT );
		graphics.endFill();
		
		selectState = NONE;
		previewState = NONE;
	}
	
	function onRemoved( e ) {
		towerSelectView.removeEventListener( Event.SELECT, onSelectBuildTower );
		removeEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		removeEventListener( MouseEvent.MOUSE_DOWN, onTouchDown );
		removeEventListener( MouseEvent.MOUSE_MOVE, onTouchMove );
		Lib.current.stage.removeEventListener( MouseEvent.MOUSE_UP, onTouchUp );
	}
	
	function onTouchDown( e ) {
		if ( touchDown ) return;
		touchDown = true;
		updatePreview( e.stageX, e.stageY );
		drawEditLayer();
	}
	
	function onTouchMove( e ) {
		if (! touchDown ) return;
		updatePreview( e.stageX, e.stageY );
		drawEditLayer();
	}
	
	function onTouchUp( e ) {
		if (! touchDown ) return;
		select();
		touchDown = false;
		drawEditLayer();
	}
	
	function updatePreview( stageX:Float, stageY:Float ) {
		if (! touchDown ) {
			previewState = NONE;
			return;
		}
		
		var local = globalToLocal( new Point( stageX, stageY ) );
		var cx = Std.int(local.x / CELL_WIDTH);
		var cy = Std.int(local.y / CELL_HEIGHT);
		if ( battle.containsPosition( cx, cy ) ) {
			var cell:TDBattleCell = battle.field[cy][cx];
			if( cell.tower != null ){
				switch( selectState ) {
					case MOVE( tower ) 
					if( tower == cell.tower && (tower.x != cx || tower.y != cy) ):
						previewState = MOVE( cx, cy, cell.tower );
					case _:
						previewState = SELECT( cell.tower );
				}
				return;
			}
		}
		
		switch( selectState ) {
			case NONE:
				previewState = NONE;
			case BUILD( tower ):
				var p = getBuildPosition( local.x, local.y, tower );
				previewState = BUILD( p.x, p.y, tower );
			case MOVE( tower ):
				var p = getBuildPosition( local.x, local.y, tower );
				previewState = MOVE( p.x, p.y, tower );
		}
	}
	
	function getBuildPosition( localX:Float, localY:Float, tower:TDBattleTower ) {
		return {
			x : Math.round( localX / CELL_WIDTH - tower.width / 2 ),
			y : Math.round( localY / CELL_HEIGHT - tower.height / 2 ),
		}
	}
	
	function select() {
		switch( previewState ) {
			case MOVE( x, y, tower ):
				if( battle.calcMovable( tower, x, y ) == null ){
					battle.addCommand( TDBattleCommand.MOVE( tower.id, x, y ) );
					TDSound.play( "hit2" );
				}
				
			case BUILD( x, y, tower ):
				if( battle.calcAddable( tower, x, y ) == null ){
					battle.addCommand( TDBattleCommand.BUILD( tower.resource.index, x, y ) );
					TDSound.play( "hit" );
				}
			case SELECT( tower ) 
			if( tower.canMove ):
				selectMoveTower( tower );
				
			case _:
		}
		
		justSelected = true;
	}
	
	function drawEditLayer() {
		switch( selectState ) {
			case MOVE( tower ):
				selectCursor.x = tower.x * CELL_WIDTH + (tower.width * CELL_WIDTH - selectCursor.width) / 2;
				selectCursor.y = tower.y * CELL_HEIGHT + (tower.height * CELL_HEIGHT - selectCursor.height) / 2;
				selectCursor.visible = true;
			case _:
				selectCursor.visible = false;
		}
		
		switch( previewState ) {
			case BUILD( x, y, tower ):
				drawEditPreview( x, y, tower, false );
				
			case MOVE( x, y, tower ):
				drawEditPreview( x, y, tower, true );
				
			case SELECT( tower ):
				if( editTowerView != null )
					editTowerView.visible = false;
				targetCursor.visible = true;
				
				targetCursor.x = tower.x * CELL_WIDTH + (tower.width * CELL_WIDTH - targetCursor.width) / 2;
				targetCursor.y = tower.y * CELL_HEIGHT + (tower.height * CELL_HEIGHT - targetCursor.height) / 2;
				targetCursor.type = TDBattleCursorType.SELECT;
			case _:
				if( editTowerView != null )
					editTowerView.visible = false;
				targetCursor.visible = false;
		}
	}
	
	function drawEditPreview( x:Int, y:Int, tower:TDBattleTower, move:Bool ) {
		editTowerView.visible = true;
		targetCursor.visible = true;
		
		var tower = editTowerView.tower;
		editTowerView.x = x * CELL_WIDTH;
		editTowerView.y = (y + tower.width) * CELL_HEIGHT - DROP_HEIGHT;
		editTowerView.alpha = 0.8;
		targetCursor.x = x * CELL_WIDTH + (tower.width * CELL_WIDTH - targetCursor.width) / 2;
		targetCursor.y = y * CELL_HEIGHT + (tower.height * CELL_HEIGHT - targetCursor.height) / 2;
		
		var warning = if ( move ) {
			battle.calcMovable( tower, x, y );
		}else {
			battle.calcAddable( tower, x, y );
		}
		
		if ( warning == null ) {
			targetCursor.type = TDBattleCursorType.TARGET;
		}else {
			targetCursor.type = TDBattleCursorType.IMPOSSIBLE;
			trace( warning );
		}
	}
	
	public function update() {
		if ( justSelected ) {
			previewState = NONE;
			drawEditLayer();
			justSelected = false;
		}
		
		var displayList:Array<{depth:Float, object:DisplayObject}> = [];
		
		for( tower in battle.towers ){
			var view = towerViewMap[ tower ];
			if ( view == null ) {
				view = towerViewMap[ tower ] = new TDBattleTowerView( tower );
				fieldLayer.addChild( view );
			}
			
			view.x = tower.x * CELL_WIDTH;
			view.y = (tower.y + tower.height) * CELL_HEIGHT;
			view.update();
			
			displayList.push({
				depth : view.getDepth(),
				object : view,
			});
		}
		
		for ( enemy in battle.enemys ) {
			var view = enemyViewMap[ enemy ];
			if ( view == null ) {
				view = enemyViewMap[ enemy ] = new TDBattleEnemyView( enemy );
				fieldLayer.addChild( view );
			}
			
			displayList.push({
				depth : view.getDepth(), 
				object : view,
			});
		}
		
		
		var nextEffects = [];
		for ( effect in effects ) {
			if ( effect.finished ) {
				if( effect.removeOnFinish )
					fieldLayer.removeChild( effect );
				continue;
			}
			
			nextEffects.push( effect );
			displayList.push({
				depth : effect.depth,
				object : effect,
			});
		}
		effects = nextEffects;
		
		//
		displayList.sort( function ( a, b ) {
			var pos = a.depth - b.depth;
			return 
				if ( pos == 0 ) 	0;
				else if ( pos > 0 ) 1;
				else 				-1;
		});
		
		var i = 0;
		for ( d in displayList ) {
			fieldLayer.swapChildren( d.object, fieldLayer.getChildAt(i++) );
		}
	}
	
	public function killEnemy( enemy:TDBattleEnemy ) {
		var view = enemyViewMap[ enemy ];
		if ( view != null ) {
			fieldLayer.removeChild( view );
			enemyViewMap.remove( enemy );
		}
	}
	
	public function draw( frame:Float ) {
		for ( towerView in towerViewMap.iterator() ) {
			towerView.draw( frame );
		}
		for ( enemyView in enemyViewMap.iterator() ) {
			enemyView.draw( frame );
		}
		for ( effect in effects ) {
			effect.progress( frame );
		}
	}
	
	public function onSelectBuildTower( e ) {
		var resource:TDBattleTowerResourceData = towerSelectView.selected;
		
		if ( editTowerView != null ) {
			editLayer.removeChild( editTowerView );
			editTowerView = null;
		}
		
		if ( resource == null ) {
			selectState = NONE;
		} else {
			var tower = new TDBattleTower( null, 0, resource );
			selectState = TDBattleFieldSelectState.BUILD( tower );
			editTowerView = new TDBattleTowerView( tower );
			drawEditLayer();
			editLayer.addChild( editTowerView );
		}
	}
	
	function selectMoveTower( tower:TDBattleTower ) {
		towerSelectView.cancel();
		if ( editTowerView != null ) {
			editLayer.removeChild( editTowerView );
			editTowerView = null;
		}
		
		if ( tower == null ) {
			selectState = NONE;
		} else {
			selectState = TDBattleFieldSelectState.MOVE( tower );
			editTowerView = new TDBattleTowerView( tower );
			editTowerView.alpha = 0.;
			drawEditLayer();
			editLayer.addChild( editTowerView );
		}
	}
	
	//
	public function towerAttack( equipment:TDBattleEquipment ) {
		var tower = equipment.tower;
		if ( tower == null ) return;
		
		var towerView:TDBattleTowerView = towerViewMap[ tower ];
		towerView.startAttackEffect( equipment, battle.frame );
		
		switch( equipment.detail ) {
			case TDBattleEquipmentData.SINGLE_TARGET_WEAPON_DATA( weapon ):
				var enemyView = enemyViewMap[ weapon.targetEnemy ];
				addEffect( new TDBattleTowerAttackEffect( enemyView, towerView, battle.frame ), enemyView.getDepth() );
		}
	}
	
	public function addEffect( effect:TDBattleEffect, depth:Float ) {
		if ( effect == null ) return;
		fieldLayer.addChild( effect );
		effects.push( effect );
		effect.depth = depth;
	}
	
	public function damageToEnemy( enemy:TDBattleEnemy, damage:Int, dead:Bool ) {
		var enemyView:TDBattleEnemyView = enemyViewMap[ enemy ];
		if ( enemyView == null ) return;
		if ( dead ) {
			enemyViewMap.remove( enemy );
			fieldLayer.removeChild( enemyView );
			TDSound.play( "shot2" );
		}
	}
	
	public function gameOver( enemy, onFinishEffect ) {
		
		//爆破
		var castleView = towerViewMap[ battle.castle ];
		var resource = Assets.getBitmapData( "img/effect/castleExplode.png" );
		var imageNum = Std.int(resource.width / EXPLODE_WIDTH);
		var effect = new TDBattleBitmapAnimation( resource, imageNum, battle.frame, imageNum / 2, false );
		
		effect.onFinish = onFinishEffect;
		effect.x = battle.castle.x * CELL_WIDTH - EXPLODE_LEFT;
		effect.y = (battle.castle.y + battle.castle.height) * CELL_HEIGHT - EXPLODE_BOTTOM;
		addEffect( effect, castleView.getDepth() );
		castleView.visible = false;
		enemyViewMap[ enemy ].visible = false;
		
		TDSound.play( "bomb" );
	}
}

enum TDBattleFieldSelectState {
	NONE;
	BUILD( tower:TDBattleTower );
	MOVE( tower:TDBattleTower );
}

enum TDBattleFieldPreviewState {
	NONE;
	BUILD( x:Int, y:Int, tower:TDBattleTower );
	SELECT( tower:TDBattleTower );
	MOVE( x:Int, y:Int, tower:TDBattleTower );
}