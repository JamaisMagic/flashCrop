package{
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	
	public class FlashCrop extends Sprite{
		private var existedImgUrl:String = 'http://demo.xwx.cn/uploads/image/b/a4/ba45c8f60456a672e003a875e469d0eb600x0.jpg';
		//private var existedImgUrl:String = '';
		private var existedImgUrlObj:URLRequest = new URLRequest(existedImgUrl);
		private var existedImgLoader:Loader = new Loader();
		
		private var fileLoader:Loader = new Loader();
		private var fileRef:FileReference = new FileReference();
		
		private var fileSelectBtn:Btn = new Btn();
		private var selectFileText:TextField = new TextField();
		
		private var confirmBtn:Btn = new Btn();
		private var confirmBtnText:TextField = new TextField();
		private var cancelBtn:Btn = new Btn();
		private var cancelBtnText:TextField = new TextField();
		
		private var cornerMaskRT:CornerMask = new CornerMask();
		private var cornerMaskLT:CornerMask = new CornerMask();
		private var cornerMaskRB:CornerMask = new CornerMask();
		private var cornerMaskLB:CornerMask = new CornerMask();
		
		private var uploadUrl:String = '/upload?fileKey=upfile';
		
		private var defaultImg:DefaultImg = new DefaultImg();
		public function FlashCrop(){
			addSelectBtn();
			
			if(existedImgUrl) {
				existedImgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,existedImgLoadedFn);
				existedImgLoader.load(existedImgUrlObj);
			} else {
				addDefaultImg();
			}
			fileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,fileLoadedFn);
			
			fileRef.addEventListener(Event.SELECT,fileSelectedFn);
			fileRef.addEventListener(Event.COMPLETE,fileRefLoadedFn);
		}
		private function existedImgLoadedFn(evt:Event):void{
			existedImgLoader.width = 150;
			existedImgLoader.height = 150;
			
			cornerMaskRT.x = 146;
			cornerMaskRT.y = 0;
			
			cornerMaskLT.x = 0;
			cornerMaskLT.y = 4;
			cornerMaskLT.rotation = 270;

			cornerMaskRB.x = 150;
			cornerMaskRB.y = 146;
			cornerMaskRB.rotation = 90;
			
			cornerMaskLB.x = 4;
			cornerMaskLB.y = 150;
			cornerMaskLB.rotation = 180;
			
			addChild(existedImgLoader);
			addChild(cornerMaskRT);
			addChild(cornerMaskLT);
			addChild(cornerMaskRB);
			addChild(cornerMaskLB);
		}
		private function fileLoadedFn(evt:Event):void{
			fileLoader.x = 200;
			fileLoader.width = 150;
			fileLoader.height = 150;
			addChild(fileLoader);
			addOperaBtn();
		}
		private function browseFile(evt:MouseEvent):void {
			fileRef.cancel();
			fileRef.browse();
		}
		private function fileSelectedFn(evt:Event):void {
			fileRef.load();
		}
		private function fileRefLoadedFn(evt:Event):void {
			fileLoader.loadBytes(fileRef.data);
		}
		private function addSelectBtn():void {
			fileSelectBtn.x = 0;
			fileSelectBtn.y = 200;
			
			selectFileText.text = '上传头像';
			selectFileText.textColor = 0xffffff;
			selectFileText.autoSize = 'center';
			selectFileText.x = 45;
			selectFileText.y = 5;
			fileSelectBtn.addChild(selectFileText);
			fileSelectBtn.addEventListener(MouseEvent.CLICK,browseFile);
			addChild(fileSelectBtn);
		}
		private function addDefaultImg():void {
			defaultImg.x = 0;
			defaultImg.y = 0;
			addChild(defaultImg);
		}
		private function addOperaBtn():void {
			confirmBtn.x = 200;
			confirmBtn.y = 200;
			confirmBtn.width = 200;
			confirmBtnText.text = '确定';
			confirmBtnText.textColor = 0xffffff;
			confirmBtnText.autoSize = 'center';
			confirmBtnText.x = 60;
			confirmBtnText.y = 5;
			confirmBtn.addChild(confirmBtnText);
			
			cancelBtn.x = 280;
			cancelBtn.y = 200;
			cancelBtn.width = 200;
			cancelBtnText.text = '取消';
			cancelBtnText.textColor = 0xffffff;
			cancelBtnText.autoSize = 'center';
			cancelBtnText.x = 60;
			cancelBtnText.y = 5;
			cancelBtn.addChild(cancelBtnText);
			
			addChild(confirmBtn);
			addChild(cancelBtn);
			confirmBtn.addEventListener(MouseEvent.CLICK,confirmFn);
			cancelBtn.addEventListener(MouseEvent.CLICK,cancelFn);
		}
		private function confirmFn(evt:MouseEvent):void {
			fileRef.upload(new URLRequest(uploadUrl),'upfile');
		}
		private function cancelFn(evt:MouseEvent):void {
			fileRef.cancel();
			confirmBtn.removeEventListener(MouseEvent.CLICK,confirmFn);
			cancelBtn.removeEventListener(MouseEvent.CLICK,cancelFn);
			removeChild(fileLoader);
			removeChild(confirmBtn);
			removeChild(cancelBtn);
		}
	}
}
