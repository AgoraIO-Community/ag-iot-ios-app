import Foundation
import UIKit

extension UIImage{
    
    //将图片缩放成指定尺寸（多余部分自动删除）
    public func scaled(to newSize: CGSize) -> UIImage {
        //计算比例
        let aspectWidth  = newSize.width/size.width
        let aspectHeight = newSize.height/size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        //图片绘制区域
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = (newSize.height - size.height * aspectRatio) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
        
    public class func resetImgSize(sourceImage : UIImage,maxImageLenght : CGFloat,maxSizeKB : CGFloat) -> Data {
        
        var maxSize = maxSizeKB
        
        var maxImageSize = maxImageLenght
        
        
        
        if (maxSize <= 0.0) {
            
            maxSize = 1024.0;
            
        }
        
        if (maxImageSize <= 0.0)  {
            
            maxImageSize = 1024.0;
            
        }
        
        //先调整分辨率
        
        var newSize = CGSize.init(width: sourceImage.size.width, height: sourceImage.size.height)
        
        let tempHeight = newSize.height / maxImageSize;
        
        let tempWidth = newSize.width / maxImageSize;
        
        if (tempWidth > 1.0 && tempWidth > tempHeight) {
            
            newSize = CGSize.init(width: sourceImage.size.width / tempWidth, height: sourceImage.size.height / tempWidth)
            
        }
            
        else if (tempHeight > 1.0 && tempWidth < tempHeight){
            
            newSize = CGSize.init(width: sourceImage.size.width / tempHeight, height: sourceImage.size.height / tempHeight)
            
        }
        
        UIGraphicsBeginImageContext(newSize)
        
        sourceImage.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
                
        var imageData = newImage?.jpegData(compressionQuality: 1)
        
        // var imageData = UIImageJPEGRepresentation(newImage!, 1.0)
        
                var sizeOriginKB : CGFloat = CGFloat((imageData?.count)!) / 1024.0;
        
                //调整大小
        
                var resizeRate = 0.9;
        
                while (sizeOriginKB > maxSize && resizeRate > 0.1) {
        
                    //imageData = UIImageJPEGRepresentation(newImage!,CGFloat(resizeRate));
                    
                    imageData = newImage?.jpegData(compressionQuality: CGFloat(resizeRate))
        
                    sizeOriginKB = CGFloat((imageData?.count)!) / 1024.0;
        
                    resizeRate -= 0.1;
        
                }
        
        return imageData!
        
    }
    
    //将颜色转换为图片
    public class func getImageWithColor(color:UIColor)->UIImage{
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    public class func setupQRCodeImage(_ text: String, image: UIImage?) -> UIImage {
        //创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        //将url加入二维码
        filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
        //取出生成的二维码（不清晰）
        if let outputImage = filter?.outputImage {
            //生成清晰度更好的二维码
            let qrCodeImage = setupHighDefinitionUIImage(outputImage, size: 300)
                //如果有一个头像的话，将头像加入二维码中心
    //            if var image = image {
    //                //给头像加一个白色圆边（如果没有这个需求直接忽略）
    //                image = circleImageWithImage(image, borderWidth: 50, borderColor: UIColor.white)
    //                //合成图片
    //                let newImage = syntheticImage(qrCodeImage, iconImage: image, width: 100, height: 100)
    //
    //                return newImage
    //            }
                
            return qrCodeImage
        }
            
        return UIImage()
    }
    
    //MARK: - 生成高清的UIImage
    public class func setupHighDefinitionUIImage(_ image: CIImage, size: CGFloat) -> UIImage {
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)
        
        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: integral)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: proportion, y: proportion);
        bitmapRef.draw(bitmapImage, in: integral);
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }
    
    /*使用Gif格式的文件，返回图片数组及加载时间
     设置设置imageView的属性，也可用于SVProgressHUD网络加载loading
     imageView.animationImages = images
     imageView.animationDuration = totalDuration
     imageView.animationRepeatCount = 0
     */
    public class func parseGIFDataToImageArray(gifName:String) -> (imageArr:[UIImage],totalDuration:TimeInterval){
        
        var imagesArr: [UIImage] = []
        var totalDuration : TimeInterval = 0
        
        //1.加载Gif图片, 并且转成Data类型
        guard let path = Bundle.main.path(forResource: gifName, ofType: nil) else { return (imagesArr,totalDuration)}
        guard let data = NSData(contentsOfFile: path) else { return (imagesArr,totalDuration)}
                
         // 2.从data中读取数据: 将data转成CGImageSource对象
         guard let imageSource = CGImageSourceCreateWithData(data, nil) else { return (imagesArr,totalDuration)}
         let imageCount = CGImageSourceGetCount(imageSource)
 
        // 3.便利所有的图片
        for i in 0..<imageCount {
            // 3.1.取出图片
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else { continue }
            
            let image = UIImage(cgImage: cgImage)
            imagesArr.append(image)
                    
            // 3.2.取出持续的时间
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) as? Dictionary<String, Any> else { continue }
            guard let gifDict = properties[kCGImagePropertyGIFDictionary as String] as? NSDictionary else { continue }
            guard let frameDuration = gifDict[kCGImagePropertyGIFDelayTime] as? NSNumber else { continue }
            totalDuration += frameDuration.doubleValue
        }
        return (imagesArr,totalDuration)
    }
}
