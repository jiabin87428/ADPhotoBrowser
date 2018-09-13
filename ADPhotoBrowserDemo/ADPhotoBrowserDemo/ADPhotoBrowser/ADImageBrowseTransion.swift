//
//  ADImageBrowseTransion.swift
//  MagicMoveTest01
//
//  Created by 李家斌 on 2018/9/10.
//  Copyright © 2018年 李家斌. All rights reserved.
//

import UIKit

class ADImageBrowseTransion: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// 屏幕的宽
    let SCREENW = UIScreen.main.bounds.size.width
    /// 屏幕的高
    let SCREENH = UIScreen.main.bounds.size.height
    
    /// iPhone X
    var isIPhoneX = false
    // 来源视图
    private var fromView: UIImageView?
    
    init(fromView: UIImageView?) {
        super.init()
        self.fromView = fromView
        if SCREENH >= 812 {
            isIPhoneX = true
        }else {
            isIPhoneX = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fvc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        // 获取动画的源控制器和目标控制器
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let container = transitionContext.containerView
        
        var snapshotView: UIImageView?
        // 创建Cell的镜像
        if fromView != nil {
            let fromFrame = container.convert(fromView!.bounds, from: fromView!)
            snapshotView = UIImageView(frame: fromFrame)
            snapshotView?.contentMode = .scaleAspectFit
            snapshotView?.image = fromView!.image
            fromView!.isHidden = true
        }
        
        // 设置目标控制器的位置，并把透明度设为0，在后面的动画中慢慢显示出来变为1
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        toVC.view.alpha = 0
        
        // 创建上一个页面的镜像图片
        let lastsnapshot = self.customSnapshoFromView(inputView: fvc!.view)
        (toVC as! ADPhotoBrowser).lastView = lastsnapshot
        
        // 都添加到 container 中。注意顺序不能错了
        container.addSubview(toVC.view)
        if snapshotView != nil {
            container.addSubview(snapshotView!)
        }
        
        // 执行动画
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {[weak self]() -> Void in
            if snapshotView != nil {
                // 设置截屏View的尺寸坐标为目标VC中ImageView的尺寸坐标
                snapshotView?.frame = toVC.view.frame
            }
            // 如果是iPhoneX，截屏的y坐标加上导航栏差的24
            if (self?.isIPhoneX)! {
//                snapshotView.frame.origin.y = toVC.view.frame.origin.y + 24;
            }
            // 目标VC透明度渐出
            toVC.view.alpha = 1
        }, completion: { [weak self](finish : Bool) -> Void in
            if self?.fromView != nil {
                self?.fromView!.isHidden = false
                snapshotView!.removeFromSuperview()
            }
            
            // 一定要记得动画完成后执行此方法，让系统管理 navigation
            transitionContext.completeTransition(true)
        })
        
        
    }
    
    // 复制UIView
    func copyView(view: UIView) -> UIView {
        let data = NSKeyedArchiver.archivedData(withRootObject: view)
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIView
    }
    
    // 创建View镜像
    func customSnapshoFromView(inputView : UIView) -> UIView {
        var imageSize = CGSize()
        let orientation = UIApplication.shared.statusBarOrientation
        if UIInterfaceOrientationIsPortrait(orientation) {
            imageSize = UIScreen.main.bounds.size
        }else {
            imageSize = CGSize(width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        }
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，可以解决截图模糊的问题
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
//        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        inputView.drawHierarchy(in: inputView.bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapShot = UIImageView.init(image: img)
        snapShot.layer.masksToBounds = false
        snapShot.layer.cornerRadius = 0.0
        snapShot.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        return snapShot
    }
}
