package myLib  {
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	public class Second extends Sprite {
		private var loader:Loader = new Loader();

		public function Second() {
			var imgFrame:Sprite = new Sprite();
			var url:String = '02.jpg';
			var urlObj:URLRequest = new URLRequest(url);
			loader.contentLoaderInfo..addEventListener(Event.COMPLETE,loadComp);
			loader.load(urlObj);
		}
		private function loadComp(evt:Event):void {
			addChild(loader);
			loader.width = 300;
			loader.height = 300;
		}
	}
}
