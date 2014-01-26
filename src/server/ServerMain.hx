import haxe.Unserializer;
import neko.Web;
import standardTD.logic.battle.log.TDBattleLog;
import standardTD.logic.battle.TDBattle;
import standardTD.master.TDBattleMasterData;

/**
 * ...
 * @author shohei909
 */
class ServerMain {
	
	static function main() {
		var start = Sys.cpuTime();
		
		Web.setHeader( "Content-Type", "text/html; charset=UTF-8" );
		Sys.println( "<html><body>" );
		
		var params:Map<String,String> = Web.getParams();
		var input = params["data"];
		
		var data:TDBattleLog = Unserializer.run( input );
		var battle = new TDBattle( TDBattleMasterData.getData( data.battleId ) );
		
		Sys.println( "ユーザー入力データから、ゲームを再現します。<br />" );
		Sys.println( "ランダムシードは、" + battle.random.seed + "です。<br /><br />" );
		
		for ( i in 0...data.frame ) {
			var commands = data.commandLog[ i ];
			if ( commands != null ) {
				for ( c in commands ){
					battle.addCommand( c );
					Sys.print( i + "f : >> 入力 : " );
					switch( c ) {
						case SKIP:
							Sys.println( "スキップしました。<br />");
						case BUILD( type, x, y ):
							Sys.println( 'タワーを設置しました。(type:$type, x:$x, y:$y)<br />');
						case MOVE( id, x, y ):
							Sys.println( 'タワーを動かしました。(id:$id, x:$x, y:$y)<br />');
					}
				}
			}
			
			var events = battle.progress();
			for ( e in events ){
				switch( e ) {
					case REJECT_COMMAND( command, message ):
						Sys.print( i + "f : << " );
						Sys.println( '不正な入力がありました。$message<br />');
					case TOWER_ATTACK( equipment ):
					case ENEMY_DAMAGED( enemy, damage, dead ):
						if ( dead ) {
							Sys.print( i + "f : << " );
							Sys.println( '${enemy.name}を撃破！<br />');
						}
					case ADD_MONEY( m ):
						Sys.print( i + "f : << " );	
						Sys.println( '${m}Gゲット！！<br />');
					case WIN:
						Sys.print( i + "f : << " );	
						Sys.println( 'ゲームクリア！！<br />');
					case LOSE( enemy ):
						Sys.print( i + "f : << " );	
						Sys.println( '${enemy.name}に敗北しました。<br />');
				}
			}
		}
		
		Sys.println( "<br />" );
		Sys.println( "計算時間 : " + (Sys.cpuTime() - start) + "秒 (t1.micro)<br />");
		Sys.println( "総フレーム数 : " + data.frame + "(" + (data.frame * (5 / 60)) + "秒)"  + "<br />");
		Sys.println( "残ったお金 : " + battle.money  + "<br />");
		Sys.println( "</body></html>" );
	}
}