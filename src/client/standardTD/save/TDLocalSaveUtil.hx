package standardTD.save;
import flash.net.SharedObject;

class TDLocalSaveUtil {
	static public var data(default, null):TDLocalSaveData;
	static var sharedObject:SharedObject;
	
	static public function save() {
		sharedObject.flush();
	}
	
	static public function load() {
		sharedObject = SharedObject.getLocal( "mainData" );
		data = sharedObject.data.saveData;
		
		if ( data == null ) {
			data = {
				useWireframe : false,
			}
			sharedObject.data.saveData = data;
		}
	}
}