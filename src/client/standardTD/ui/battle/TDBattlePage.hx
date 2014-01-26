package standardTD.ui.battle;
import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import openfl.Assets;
import standardTD.logic.battle.enemy.TDBattleWaveState;
import standardTD.logic.battle.log.TDBattleCommand;
import standardTD.logic.battle.log.TDBattleInitialData;
import standardTD.logic.battle.TDBattle;
import standardTD.logic.battle.TDBattleEvent;
import standardTD.master.TDBattleMasterData;
import standardTD.sound.TDSound;
import standardTD.ui.battle.part.TDBattleFieldView;
import standardTD.ui.battle.part.TDBattleGameOverLayer;
import standardTD.ui.battle.part.TDBattleTowerSelectView;
import standardTD.ui.battle.part.TDBattleSkipButton;
import standardTD.ui.battle.part.TDBattleWaveView;
import standardTD.ui.common.TDMoneyLabel;
import standardTD.save.TDLocalSaveData;
import standardTD.save.TDLocalSaveUtil;
import standardTD.ui.common.TDPage;

/**
 * ...
 * @author shohei909
 */

class TDBattlePage extends TDPage {
	static public inline var BATTLE_UPDATE_SPAN:Int = 5;
	
	public var pageFrame:Int;
	public var background:Bitmap;
	public var nextWaveLabel:Bitmap;
	public var fieldView:TDBattleFieldView;
	public var battle:TDBattle;
	public var skipButton:TDBattleSkipButton;
	public var selectView:TDBattleTowerSelectView;
	public var editView:TDBattleTowerSelectView;
	public var waveView:TDBattleWaveView;
	public var moneyLabel:TDMoneyLabel;
	public var gameOverLayer:TDBattleGameOverLayer;
	
	public function new() {
		super();
		battle = new TDBattle( TDBattleMasterData.getData( "0" ) );
		
		background = new Bitmap( Assets.getBitmapData( "img/ui/battle/background.png" ) );
		addChild( background );
		
		selectView = new TDBattleTowerSelectView( battle );
		selectView.x = 1;
		selectView.y = Main.screenHeight - TDBattleTowerSelectView.HEIGHT;
		addChild( selectView );
		
		fieldView = new TDBattleFieldView( battle, selectView );
		fieldView.y = 19;
		addChild( fieldView );
		
		waveView = new TDBattleWaveView( battle );
		waveView.x = TDBattleFieldView.CELL_WIDTH * 3;
		waveView.y = 0;
		addChild( waveView );
		
		moneyLabel = new TDMoneyLabel( 9 );
		moneyLabel.x = Main.screenWidth - moneyLabel.width;
		moneyLabel.y = Main.screenHeight - moneyLabel.height;
		
		addChild( moneyLabel );
		
		nextWaveLabel = new Bitmap( Assets.getBitmapData( "img/ui/battle/nextWaveText.png" ) );
		addChild( nextWaveLabel );
		nextWaveLabel.x = TDBattleFieldView.CELL_WIDTH * 3;
		nextWaveLabel.y = 1;
		
		skipButton = new TDBattleSkipButton();
		skipButton.x = 0;
		skipButton.y = 1;
		skipButton.addEventListener( MouseEvent.MOUSE_UP, onSkipButton );
		addChild( skipButton );
		
		gameOverLayer = new TDBattleGameOverLayer( battle );
		gameOverLayer.visible = false;
		addChild( gameOverLayer );
		
		pageFrame = 0;
		TDSound.playBGM( "saranarukunan" );
	}
	
	override public function update():Void {
		super.update();
		
		if ( pageFrame % BATTLE_UPDATE_SPAN == 0 ) {
			var events = battle.progress();
			
			fieldView.update();
			selectView.update();
			waveView.update();
			moneyLabel.setNumber( battle.money );
			var shooted = false;
			
			for ( event in events ) {
				switch( event ) {
					case TDBattleEvent.WIN :
						finish();
						gameOverLayer.show( true );
						
					case TDBattleEvent.LOSE( enemy ):
						lose( enemy );
						
					case TDBattleEvent.TOWER_ATTACK( equipment ) : 
						fieldView.towerAttack( equipment );
						
					case TDBattleEvent.ENEMY_DAMAGED( enemy, damage, dead ) :
						fieldView.damageToEnemy( enemy, damage, dead );
						if( !shooted ){
							TDSound.play( "shot" );
							shooted = true;
						}
					case TDBattleEvent.REJECT_COMMAND( _, _ ) :
						
					case TDBattleEvent.ADD_MONEY( _ ):
				}
			}
			
			skipButton.setState( battle.waveState );
		}
		
		var frame:Float = pageFrame / BATTLE_UPDATE_SPAN + 1;
		fieldView.draw( frame );
		pageFrame++;
	}
	
	function onSkipButton( e ) {
		battle.addCommand( TDBattleCommand.SKIP );
		TDSound.play( "comical" );
	}
	
	public function lose( enemy ) {
		finish();
		fieldView.gameOver( enemy, gameOverLayer.show.bind( false ) );
	}
	
	function finish() {
		TDSound.stopBGM();
		fieldView.mouseEnabled = false;
		fieldView.mouseChildren = false;
		selectView.mouseEnabled = false;
		selectView.mouseChildren = false;
	}
}
