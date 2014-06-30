package{
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;
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
		
		private var fileLoaderBack:Sprite = new Sprite();
		
		private var fileLoader:Loader = new Loader();
		private var fileRef:FileReference = new FileReference();
        private var previewImg:Loader = new Loader();

        private var currentImgWidth:Number = 0;
        private var currentImgHeight:Number = 0;
        private var oriImgWidth:Number = 0;
        private var oriImgHeight:Number = 0;

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
		
		private var maskAll:OperaMaskAll = new OperaMaskAll();
        private var scaleIcon:ScaleIcon = new ScaleIcon();
        private var scaleIconW:Number = 11;
        private var scaleStartY:Number = squareWidth;
		
		private var iniShorter:Number = 13; 
		private var iniLonger:Number = 124;
		private var minSquareWidth:Number = 20;
		private var defaultImgWidth:Number = 150;
		private var squareWidth:Number = iniLonger;
		private var viewPortX:Number = 0;
		private var viewPortY:Number = 0;
		
		private var moveStartX:Number = 0;
		private var moveStartY:Number = 0;
		private var moveEndX:Number = 0;
		private var moveEndY:Number = 0;

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
			previewImg.contentLoaderInfo.addEventListener(Event.COMPLETE,previewImgLoadedFn);

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
			
			var imgWidth:Number = fileLoader.contentLoaderInfo.content.width;
			var imgHeight:Number = fileLoader.contentLoaderInfo.content.height;

            oriImgWidth = imgWidth;
            oriImgHeight = imgHeight;
			
			var ratioResult:Array = ratioScale(imgWidth,imgHeight);
			var resultWidth = currentImgWidth = ratioResult[0];
			var resultHeight = currentImgHeight = ratioResult[1];

			if(resultWidth >= resultHeight) {
				fileLoader.x = 0;
				fileLoader.y = (resultWidth - resultHeight) / 2;
			} else {
				fileLoader.y = 0;
				fileLoader.x = (resultHeight - resultWidth) / 2;
			}
			fileLoader.width = resultWidth;
			fileLoader.height = resultHeight;

			fileLoaderBack.addChild(fileLoader);
			addFileLoaderBackground();
			addOperaBtn();
			iniMask(fileLoader.x,fileLoader.y,resultWidth,resultHeight);
		}
        private function previewImgLoadedFn(evt:Event):void{
            //previewImg.x = 400;
            //previewImg.y = 0;
            //previewImg.width = defaultImgWidth;
            //previewImg.height = defaultImgWidth;
            //addChild(previewImg);
        }
        private function updatePreviewImg():void{
            var rect:Rectangle = new Rectangle(0, 0, defaultImgWidth, defaultImgWidth);
            rect.x = (viewPortX - fileLoader.x) / fileLoader.width * oriImgWidth;
            rect.y = (viewPortY - fileLoader.y) / fileLoader.height * oriImgHeight;
            rect.width = squareWidth / currentImgWidth * oriImgWidth;
            rect.height = squareWidth / currentImgHeight * oriImgHeight;
            var destPoint:Point = new Point(0,0);

            var b:Bitmap = Bitmap(previewImg.content);
            var preBmd:BitmapData = b.bitmapData;
            var preBmdClode:BitmapData = new BitmapData(squareWidth / currentImgWidth * oriImgWidth,  squareWidth / currentImgHeight * oriImgHeight);

            preBmdClode.copyPixels(preBmd,rect,destPoint);

            var drawBitmap:Bitmap = new Bitmap(preBmdClode);
            drawBitmap.x = 400;
            drawBitmap.y = 0;
            drawBitmap.width = defaultImgWidth;
            drawBitmap.height= defaultImgWidth;

            trace(rect.x,rect.y,rect.width,rect.height);
            addChild(drawBitmap);
        }
        private function addFileLoaderBackground():void {
			
			fileLoaderBack.scaleX = fileLoaderBack.scaleY = 1;
			fileLoaderBack.x = 200;
			fileLoaderBack.y = 0;
			fileLoaderBack.graphics.moveTo(0,0);
			fileLoaderBack.graphics.beginFill(0x000000);
			fileLoaderBack.graphics.drawRect(0,0,150,150);
			addChild(fileLoaderBack);
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
            previewImg.loadBytes(fileRef.data);
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
			confirmBtn.scaleX = confirmBtn.scaleY = cancelBtn.scaleX = cancelBtn.scaleY = 1;
			confirmBtn.x = 200;
			confirmBtn.y = 200;
			
			confirmBtnText.text = '确定';
			confirmBtnText.textColor = 0xffffff;
			confirmBtnText.autoSize = 'center';
			confirmBtnText.x = 60;
			confirmBtnText.y = 5;
			confirmBtn.addChild(confirmBtnText);
			confirmBtn.width = 200;
			
			cancelBtn.x = 280;
			cancelBtn.y = 200;
			
			cancelBtnText.text = '取消';
			cancelBtnText.textColor = 0xffffff;
			cancelBtnText.autoSize = 'center';
			cancelBtnText.x = 60;
			cancelBtnText.y = 5;
			cancelBtn.addChild(cancelBtnText);
			cancelBtn.width = 200;

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
		private function iniMask(loaderX:Number,loaderY:Number,loaderW:Number,loaderH:Number):void {

			squareWidth = loaderW === loaderH ? iniLonger : Math.min(loaderW,loaderH) >= iniLonger ? iniLonger : Math.min(loaderW,loaderH);
			squareWidth = squareWidth < minSquareWidth ? minSquareWidth : squareWidth;

            viewPortX = viewPortY = (defaultImgWidth -  squareWidth) / 2;

            maskAll.x = 200;
            maskAll.y = 0;

            scaleIcon.x = squareWidth + viewPortX - scaleIconW;
            scaleIcon.y = squareWidth + viewPortY - scaleIconW;

			maskAll.graphics.clear();
			
			maskAll.graphics.moveTo(0,0);
			maskAll.graphics.beginFill(0xffffff,0.7);

			if(loaderW - loaderH > iniShorter * 2 ) {
				maskAll.graphics.drawRect((loaderW - squareWidth) / 2 + squareWidth + loaderX,loaderY,(loaderW - squareWidth) / 2,loaderH);
				maskAll.graphics.drawRect(loaderX,loaderY,(loaderW - squareWidth) / 2,loaderH);
				
			} else if (loaderW - loaderH < -(iniShorter * 2)) {
				maskAll.graphics.drawRect(loaderX,loaderY,loaderW,(loaderH - squareWidth) / 2);
				maskAll.graphics.drawRect(loaderX,(loaderH - squareWidth) / 2 + squareWidth,loaderW ,(loaderH - squareWidth) / 2);
			} else {
				maskAll.graphics.drawRect(loaderX,loaderY,loaderW,(loaderH - squareWidth) / 2);
				maskAll.graphics.drawRect(loaderX,loaderH - (loaderH - squareWidth) / 2 + + loaderY,loaderW,(loaderH - squareWidth) / 2);
				
				maskAll.graphics.drawRect((loaderW - squareWidth) / 2 + squareWidth + loaderX,(loaderH - squareWidth) / 2 + loaderY,(loaderW - squareWidth) / 2,squareWidth);
				maskAll.graphics.drawRect(loaderX,(loaderH - squareWidth) / 2 + loaderY,(loaderW - squareWidth) / 2,squareWidth);
			}

			maskAll.addEventListener(MouseEvent.MOUSE_DOWN,maskDownFn);
            maskAll.addChild(scaleIcon);
            updatePreviewImg();
			addChild(maskAll);
			
		}
		private function maskDownFn(evt:MouseEvent):void {
			var localX:Number = evt.localX;
			var localY:Number = evt.localY;
            if(evt.target === scaleIcon) {
                scaleStartY = evt.localY + scaleIcon.y;
                maskAll.addEventListener(MouseEvent.MOUSE_MOVE,scaleMoveFn);
                maskAll.addEventListener(MouseEvent.MOUSE_UP,scaleUpFn);

                maskAll.removeEventListener(MouseEvent.MOUSE_MOVE,maskMoveFn);
            } else if(localX > viewPortX && localX < viewPortX + squareWidth && localY > viewPortY && localY < viewPortY + squareWidth) {
                moveStartX = evt.localX;
                moveStartY = evt.localY;
                maskAll.addEventListener(MouseEvent.MOUSE_MOVE,maskMoveFn);
                maskAll.addEventListener(MouseEvent.MOUSE_UP,maskUpFn);

                maskAll.removeEventListener(MouseEvent.MOUSE_MOVE,scaleMoveFn);
            }
		}
		private function maskMoveFn(evt:MouseEvent):void {
            viewPortX = viewPortX + (evt.localX - moveStartX);
            viewPortY = viewPortY + (evt.localY - moveStartY);
            moveStartX = evt.localX;
            moveStartY = evt.localY;
            updateBorderMask();
            updatePreviewImg();
			evt.updateAfterEvent();
		}
		private function maskUpFn(evt:MouseEvent):void {
			maskAll.removeEventListener(MouseEvent.MOUSE_MOVE,maskMoveFn);
			maskAll.removeEventListener(MouseEvent.MOUSE_UP,maskUpFn);
		}
        private function scaleMoveFn(evt:MouseEvent):void {
            if(evt.target === scaleIcon) {
                squareWidth = evt.localY + scaleIcon.y - scaleStartY + squareWidth;
                scaleStartY = evt.localY + scaleIcon.y;
            } else {
                squareWidth = evt.localY - scaleStartY + squareWidth;
                scaleStartY = evt.localY;
            }
            if(squareWidth > Math.min(fileLoader.width,fileLoader.height)) {
                squareWidth = Math.min(fileLoader.width,fileLoader.height);
            }
            if(squareWidth < minSquareWidth) {
                squareWidth = minSquareWidth;
            }
            updateBorderMask();
            updatePreviewImg();

            evt.updateAfterEvent();
        }
        private function scaleUpFn(evt:MouseEvent):void {
            maskAll.removeEventListener(MouseEvent.MOUSE_MOVE,scaleMoveFn);
            maskAll.removeEventListener(MouseEvent.MOUSE_UP,scaleUpFn);
        }
        private function updateBorderMask():void {
            maskAll.graphics.clear();
            maskAll.graphics.beginFill(0xffffff,0.7);

            if(viewPortX < fileLoader.x) {
                viewPortX = fileLoader.x;
            }
            if(viewPortX > fileLoader.width - squareWidth + fileLoader.x) {
                viewPortX = fileLoader.width - squareWidth + fileLoader.x;
            }
            if(viewPortY < fileLoader.y) {
                viewPortY = fileLoader.y;
            }
            if(viewPortY > fileLoader.height - squareWidth + fileLoader.y) {
                viewPortY = fileLoader.height - squareWidth + fileLoader.y;
            }
            //左右
            maskAll.graphics.drawRect(viewPortX + squareWidth,viewPortY, squareWidth === fileLoader.width ? 0 : fileLoader.width + fileLoader.x - viewPortX - squareWidth ,squareWidth);
            maskAll.graphics.drawRect(fileLoader.x,viewPortY, squareWidth === fileLoader.width ? 0 : viewPortX - fileLoader.x ,squareWidth);
            //上下
            maskAll.graphics.drawRect(viewPortX - (viewPortX - fileLoader.x),fileLoader.y,fileLoader.width,squareWidth === fileLoader.height ? 0 : viewPortY - fileLoader.y);
            maskAll.graphics.drawRect(viewPortX - (viewPortX - fileLoader.x),viewPortY + squareWidth,fileLoader.width,squareWidth === fileLoader.height ? 0 : fileLoader.height + fileLoader.y - viewPortY - squareWidth);

            scaleIcon.x = squareWidth + viewPortX - scaleIconW;
            scaleIcon.y = squareWidth + viewPortY - scaleIconW;
        }
		private function ratioScale(width:Number,height:Number):Array {
			var ratio:Number = width / height;
			if(width === height) {
				width = height = 150;
			}
			if(width > height) {
				width = 150;
				height = Math.floor(width / ratio);
			}
			if(width < height) {
				height = 150;
				width = Math.floor(height * ratio);
			}
			return [width,height];
		}
	}
}
