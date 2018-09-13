//
//  ADImageBrowsePopTransion.swift
//  MagicMoveTest01
//
//  Created by 李家斌 on 2018/9/10.
//  Copyright © 2018年 李家斌. All rights reserved.
//

import UIKit

class ADImageBrowsePopTransion: NSObject, UIViewControllerAnimatedTransitioning {
    // 来源视图
    private var fromView: UIImageView?
    // 销毁视图方式：1：单击销毁 2：下扫销毁
    private var dismissType = 1
    init(dismissType: Int = 1, fromView: UIImageView?) {
        super.init()
        self.dismissType = dismissType
        self.fromView = fromView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        // 获取动画的源控制器和目标控制器
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ADPhotoBrowser
        let container = transitionContext.containerView
        
        var snapFrame: CGRect?
        if self.dismissType == 1 {
            // 当dismissType为1的时候，说明是点击退出的页面
            let imgWidth = UIScreen.main.bounds.size.width
            let imgHeight = fromVC.loopView!.currentShowImgView!.image == nil ? imgWidth : (fromVC.loopView!.currentShowImgView!.image!.size.height * imgWidth)/fromVC.loopView!.currentShowImgView!.image!.size.width
            let y = (UIScreen.main.bounds.size.height - imgHeight) / 2
            let snapFrame1 = CGRect(x: 0, y: y, width: imgWidth, height: imgHeight)
            snapFrame = snapFrame1
        }else {
            // 当dismissType为2的时候，说明是向下扫动退出的页面
            snapFrame = fromVC.paningImageView?.frame
            fromVC.paningImageView?.removeFromSuperview()
        }
        
        var snapshotView: UIImageView?
        if fromView != nil {
            snapshotView = UIImageView(frame: snapFrame!)
            snapshotView?.contentMode = .scaleAspectFill
            snapshotView?.clipsToBounds = true
            snapshotView?.backgroundColor = .black
            snapshotView?.image = fromVC.loopView!.currentShowImgView!.image!
            fromVC.loopView!.currentShowImgView!.isHidden = true
        }
        
        // 设置目标控制器的位置，并把透明度设为0，在后面的动画中慢慢显示出来变为1
        //        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        if toVC != nil {
            let screenShot = customSnapshoFromView(inputView: toVC!.view)
            // 都添加到 container 中。注意顺序不能错了
            container.insertSubview(screenShot, belowSubview: fromVC.view)
        }
        if snapshotView != nil {
            container.addSubview(snapshotView!)
        }
        
        // 执行动画
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {[weak self]() -> Void in
            if snapshotView != nil {
                snapshotView!.frame = container.convert((self?.fromView!.bounds)!, from: self?.fromView!)
            }
            fromVC.view.alpha = 0
            }, completion: {[weak self](finish : Bool) -> Void in
                if self?.fromView != nil {
                    self?.fromView!.isHidden = false
                    snapshotView!.removeFromSuperview()
                }
                fromVC.loopView!.currentShowImgView!.isHidden = false
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
        
    }
    
    
    // 创建View镜像
    func customSnapshoFromView(inputView : UIView) -> UIView {
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，可以解决截图模糊的问题
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, UIScreen.main.scale)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapShot = UIImageView.init(image: img)
        snapShot.layer.masksToBounds = false
        snapShot.layer.cornerRadius = 0.0
        snapShot.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        return snapShot
    }
}
