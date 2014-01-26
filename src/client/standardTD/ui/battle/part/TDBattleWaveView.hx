package standardTD.ui.battle.part;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import standardTD.logic.battle.enemy.TDBattleWaveState;
import standardTD.logic.battle.TDBattle;

/**
 * ...
 * @author shohei909
 */

class TDBattleWaveView extends Bitmap {
	static public var HEIGHT:Int = 16;
	static public var INTERVAL:Int = 1;
	var battle:TDBattle;
	
	public function new( battle:TDBattle ) {
		super( new BitmapData( Main.screenWidth, HEIGHT, true, 0 ) );
		this.battle = battle;
	}
	
	public function update() {
		switch( battle.waveState ) {
			case TDBattleWaveState.INTERVAL( _ ) :
				var wave = battle.waves[ battle.waveIndex ];
				displayArray( wave.enemys );
				
			case TDBattleWaveState.ATTACK( index, _ ) :
				var enemys = battle.waves[ battle.waveIndex ].enemys;
				var arr = [for (i in index...enemys.length) enemys[i]];
				displayArray( arr );
				
			case TDBattleWaveState.FINISHED :
				bitmapData.fillRect( bitmapData.rect, 0 );
		}
	}
	
	function displayArray( enemys:Array<Int> ) {
		bitmapData.fillRect( bitmapData.rect, 0 );
		var x = 0;
		for ( enemyIndex in enemys ) {
			var name = battle.enemyResource[ enemyIndex ].name;
			var resource = Assets.getBitmapData( 'img/enemy/$name.png' );
			var height = resource.height;
			var width = Std.int(resource.width / 4);
			var rect = new Rectangle( 0, 0, width, height );
			bitmapData.copyPixels( resource, rect, new Point(x, HEIGHT - height) );
			x += INTERVAL + width;
		}
	}
}