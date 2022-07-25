import UIKit

/// 避免多次点击
public typealias ActionBlock = ((UIButton)->Void)

extension UIButton{
    
    private struct RuntimeKey {
        static let clickEdgeInsets = UnsafeRawPointer.init(bitPattern: "clickEdgeInsets".hashValue)
    }
    
    private struct AssociatedKeys {
        static var ActionBlock = "ActionBlock"
        static var ActionDelay = "ActionDelay"
    }
    
    ///扩大UIButton的点击范围
    ///【如果(top/left/bottom/right)值>0向外扩大区域，小于0缩小区域】
    public var hitEdgeInsets: UIEdgeInsets? {
        set {
            objc_setAssociatedObject(self, UIButton.RuntimeKey.clickEdgeInsets!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            
            let edgeInset:UIEdgeInsets? = objc_getAssociatedObject(self, UIButton.RuntimeKey.clickEdgeInsets!) as? UIEdgeInsets
            guard let edgeV =  edgeInset else {
                return UIEdgeInsets.zero
            }
            return edgeV
        }
    }
    
    /// 避免多次点击
    public var actionBlock: ActionBlock? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ActionBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ActionBlock) as? ActionBlock
        }
    }
    
    public var actionDelay: TimeInterval {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ActionDelay, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ActionDelay) as? TimeInterval ?? 0
        }
    }
    
    // 重写系统方法修改点击区域
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        var bounds = self.bounds
        
        guard let hitEdgeInsets = hitEdgeInsets else {
            return super.point(inside: point, with: event)
        }
        
        let leftV:CGFloat = hitEdgeInsets.left
        let topV:CGFloat = hitEdgeInsets.top
        let rightV:CGFloat = hitEdgeInsets.right
        let bottomV:CGFloat = hitEdgeInsets.bottom
        let x: CGFloat = -leftV
        let y: CGFloat = -topV
        let width: CGFloat = bounds.width + leftV + rightV
        let height: CGFloat = bounds.height + topV + bottomV
        bounds = CGRect(x: x, y: y, width: width, height: height)
        
        return bounds.contains(point)
    }
    
    @objc private func btnDelayClick(_ button: UIButton) {
        actionBlock?(button)
        isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + actionDelay) { [weak self] in
            self?.isEnabled = true
        }
    }
    
    public func addAction(_ delay: TimeInterval = 0, action: @escaping ActionBlock) {
        addTarget(self, action: #selector(btnDelayClick(_:)) , for: .touchUpInside)
        actionDelay = delay
        actionBlock = action
    }
    
    /// 逆时针方向
    public enum Position { case top, left, bottom, right }
    
    /// 重置图片image与标题title位置(默认间距为0)
    public func adjustImageTitlePosition(_ position: Position, spacing: CGFloat = 0 ) {
        self.sizeToFit()
        
        let imageWidth = self.imageView?.image?.size.width
        let imageHeight = self.imageView?.image?.size.height
        
        let labelWidth = self.titleLabel?.frame.size.width
        let labelHeight = self.titleLabel?.frame.size.height
        
        switch position {
        case .top:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight! - spacing / 2, left: 0, bottom: 0, right: -labelWidth!)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!, bottom: -imageHeight! - spacing / 2, right: 0)
            break
            
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing / 2, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing * 1.5, bottom: 0, right: 0)
            break
            
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight! - spacing / 2, right: -labelWidth!)
            titleEdgeInsets = UIEdgeInsets(top: -imageHeight! - spacing / 2, left: -imageWidth!, bottom: 0, right: 0)
            break
            
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth! + spacing / 2, bottom: 0, right: -labelWidth! - spacing / 2)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth! - spacing / 2, bottom: 0, right: imageWidth! + spacing / 2)
            break
        }
    }
    
}
