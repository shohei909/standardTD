package standardTD.ui.common;
import flash.display.Sprite;
import flash.Lib;
import flash.media.Sound;
import haxe.macro.Expr.Var;
import standardTD.sound.TDSound;
import standardTD.ui.battle.TDBattlePage;
import standardTD.ui.top.TDTopPage;

/**
 * ...
 * @author shohei909
 */
class TDPageManager {
	public var currentPage(default, null):TDPage;
	public var parentSprite(default, null):Sprite;
	
	public function new( parentSprite:Sprite ) {
		this.parentSprite = parentSprite;
	}
	
	public function transfer( pageType:TDPageType, fadeTime:Float ) {
		var page = switch( pageType ) {
			case TDPageType.BATTLE_PAGE : 
				new TDBattlePage();
				
			case TDPageType.TOP_PAGE :
				new TDTopPage();
		}
		
		tranferWithPage( page, fadeTime );
	}
	
	function tranferWithPage( page:TDPage, fadeTime:Float ) {
		if (currentPage != null) {
			parentSprite.removeChild( currentPage );
		}
		
		currentPage = page;
		parentSprite.addChild( currentPage );
	}
	
	public function update() {
		if (currentPage != null && !currentPage.pausing) {
			currentPage.update();
		}
	}
	
	public function resize() {
		if ( currentPage != null ) {
			currentPage.y = (Main.screenHeight - 120) / 2;
			currentPage.resize();
		}
	}
}