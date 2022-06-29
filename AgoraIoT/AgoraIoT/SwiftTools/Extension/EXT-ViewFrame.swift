import UIKit

extension Int{
    
    public var S:CGFloat {
      
       return CGFloat(self)*ScreenZS
    }
    
    public var VS:CGFloat {
      
       return CGFloat(self)*ScreenHS
    }
}

extension Double{
    
    public var S:CGFloat{
        
       return CGFloat(self)*ScreenZS
    }
    
    public var VS:CGFloat {
      
       return CGFloat(self)*ScreenHS
    }
}

extension CGFloat{
    
    public var S: CGFloat{
     
        return self*ScreenZS
    }
    
    public var VS:CGFloat {
      
       return CGFloat(self)*ScreenHS
    }
    
}

public extension UIView{
    
    //以下带S的方法是为了适配多屏幕进行等比缩放
    convenience init(frameS:CGRect){
        
        self.init(frame:CGRect(x: frameS.origin.x*ScreenZS,
                               y: frameS.origin.y*ScreenZS,
                               width: frameS.width*ScreenZS,
                               height: frameS.height*ScreenZS))
    }
    
    var frameS:CGRect{
        
        get{
            return frame
        }
        
        set{
            
            frame=CGRect(x: newValue.origin.x*ScreenZS,
                         y: newValue.origin.y*ScreenZS,
                         width: newValue.width*ScreenZS,
                         height: newValue.height*ScreenZS)
        }
    }
    
    var xS:CGFloat{
        get{
            return frame.origin.x
        }
        set{
            frame.origin.x=newValue*ScreenZS
        }
    }
    
    var yS:CGFloat{
        get{
            return frame.origin.y
        }
        set{
            frame.origin.y=newValue*ScreenZS
        }
    }
    
    var widthS:CGFloat{
        get{
            //frame可以直接.出获取宽,高,但直接.出的无法设置,需要继续.到size级别设置
            return frame.width
        }
        set{
            frame.size.width=newValue*ScreenZS
        }
    }
    var heightS:CGFloat{
        get{
            return frame.height
        }
        set{
            frame.size.height=newValue*ScreenZS
        }
    }
    var centerXS:CGFloat{
        get{
            return center.x
        }
        set{
            center.x=newValue*ScreenZS
        }
    }
    var centerYS:CGFloat{
        get{
            return center.y
        }
        set{
            center.y=newValue*ScreenZS
        }
        
    }
    var sizeS:CGSize{
        get{
            return frame.size
        }
        set{
            frame.size=CGSize(width: newValue.width*ScreenZS, height: newValue.height*ScreenZS)
        }
    }
    var originS:CGPoint{
        get{
            return frame.origin
        }
        set{
            frame.origin=CGPoint(x: newValue.x*ScreenZS, y: newValue.y*ScreenZS)
        }
    }
    
    
    //以下方法未做缩放都是原值
    var x:CGFloat{
        get{
           return frame.origin.x
        }
        set{
            frame.origin.x=newValue
        }
    }
    var y:CGFloat{
        get{
        return frame.origin.y
        }
        set{
         frame.origin.y=newValue
        }
    }
    var width:CGFloat{
        get{
        //frame可以直接.出获取宽,高,但直接.出的无法设置,需要继续.到size级别设置
         return frame.width
        }
        set{
         frame.size.width=newValue
        }
    }
    var height:CGFloat{
        get{
         return frame.height
        }
        set{
         frame.size.height=newValue
        }
    }
    var centerX:CGFloat{
        get{
         return center.x
        }
        set{
         center.x=newValue
        }
    }
    var centerY:CGFloat{
        get{
        return center.y
        }
        set{
        center.y=newValue
        }
        
    }
    var size:CGSize{
        get{
         return frame.size
        }
        set{
           frame.size=newValue
        }
    }
    var origin:CGPoint{
        get{
         return frame.origin
        }
        set{
         frame.origin=newValue
        }
    }
    
    class func viewFromNib() -> UIView {
    
         var clsStr = NSStringFromClass(self.classForCoder())
       
        clsStr = clsStr.components(separatedBy: ".").last!
        
        return Bundle.main.loadNibNamed(clsStr, owner: nil, options: nil)?.first as! UIView
    }
    
   class func viewFromNib(nibname:String) -> UIView {
        
        var clsStr = NSStringFromClass(self.classForCoder())
        
        clsStr = clsStr.components(separatedBy: ".").last!
        
        let loadName = nibname == nil ? clsStr : nibname
        
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! UIView
    }
    
    func layoutConstraint(){
        
        for constObj in constraints {
            
            constObj.constant = constObj.constant*ScreenZS
        }
        
        traverseAllSubviews(self)
    }
    
    
    func traverseAllSubviews(_ view:UIView) {
        
        for subV in view.subviews {
            
            if subV.subviews.count > 0{
             
               traverseAllSubviews(subV)
            }
            
            for constObj in subV.constraints{
                
                constObj.constant = constObj.constant*ScreenZS
            }
        }
    }
}

