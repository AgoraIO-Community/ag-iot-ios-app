import UIKit

fileprivate let ScreenScale = UIScreen.main.scale

extension UIImage{
    
    //大图压缩成小图
   public func dwl_compressSmall(sWidth:CGFloat) -> UIImage? {
        let nWidth = sWidth*ScreenZS
        
        let sHeight = (size.height*nWidth)/size.width
       
        let sSize = CGSize(width: nWidth, height: sHeight)
       
        UIGraphicsBeginImageContextWithOptions(sSize, false, ScreenScale)
        
        draw(in: CGRect(origin: CGPoint.zero, size: sSize))
        
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
            UIGraphicsEndImageContext()
        
        return img
    }
    
    public func dwl_clipRound(sWidth:CGFloat,borderColor:UIColor=UIColor.white,borderWidth:CGFloat=0) -> UIImage? {
        
        let nWidth = sWidth*ScreenZS
        let nBorderWidth = borderWidth*ScreenZS
        
        let sSize=CGSize(width:nWidth,height:nWidth)
        
        UIGraphicsBeginImageContextWithOptions(sSize, false,ScreenScale)
        //制作背景path
        let backPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: sSize))
        
        borderColor.set()
        backPath.fill()
        
        //新尺寸
        let point = nBorderWidth
        let clipW = nWidth-2*nBorderWidth
        
        let clipRect=CGRect(x:point, y: point, width: clipW, height: clipW)
        
        let clipPath=UIBezierPath(ovalIn: clipRect)
        clipPath.addClip()
        
        draw(in: clipRect)

        guard let img=UIGraphicsGetImageFromCurrentImageContext() else{
            UIGraphicsEndImageContext()
            return nil
        }
        
        UIGraphicsEndImageContext()
        return img
    }
}

extension UIImage {
    
    //MARK:生成渐变图片
    public convenience init(gradientColors:[UIColor], size:CGSize) {
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colors:[CGColor] = gradientColors.map { (color) -> CGColor in
            color.cgColor as CGColor
        }
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)
        
        ctx?.drawLinearGradient(gradient!, start: CGPoint(x: size.width/2, y: 0), end: CGPoint(x: size.width/2, y: size.height), options: CGGradientDrawingOptions(rawValue: 0))
        self.init(cgImage: ((UIGraphicsGetImageFromCurrentImageContext()?.cgImage)!))
    }
}
