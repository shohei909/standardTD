package standardTD.debug;
import haxe.CallStack;
import haxe.Log;
import haxe.PosInfos;

/**
 * ...
 * @author shohei909
 */
class DebugTools{
	dynamic static public function error( message:Dynamic, ?callStack:Array<StackItem>, ?posInfos:PosInfos ) {
		var str = "Error : " + message;
		if ( callStack != null )
			str += "\n" + CallStack.toString( callStack );
			
		Log.trace( str, posInfos );
	}
	
	dynamic static public function warning( message:Dynamic, ?posInfos:PosInfos ) {
		Log.trace( "Warning : " + message, posInfos );
	}
}