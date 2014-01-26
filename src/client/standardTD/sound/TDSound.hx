package standardTD.sound;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import openfl.Assets;

/**
 * ...
 * @author shohei909
 */
class TDSound {
	static public var bgmChannel:SoundChannel;
	
	static public function playBGM( name:String ) {
		if ( bgmChannel != null ) {
			bgmChannel.stop();
		}
		
		var sound:Sound = Assets.getMusic( 'sound/bgm/$name.mp3' );
		if( sound != null )
			bgmChannel = sound.play( 0, 0xFFFFFF );
	}
	
	static public function stopBGM() {
		if ( bgmChannel != null ) {
			bgmChannel.stop();
			bgmChannel = null;
		}
	}
	
	static public function play( name:String ) {
		var sound:Sound = Assets.getMusic( 'sound/se/$name.mp3' );
		if( sound != null )
			sound.play( 0, 0, new SoundTransform( 0.55 ) );
	}
}