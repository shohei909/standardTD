package standardTD.logic.battle.error;

enum TDBattleError {
	// 受け取ったコマンドを無視すれば継続可能な、エラー。
	REJECT( string:String ); 
	
	// 致命的なエラー。
	FATAL( string:String );
}