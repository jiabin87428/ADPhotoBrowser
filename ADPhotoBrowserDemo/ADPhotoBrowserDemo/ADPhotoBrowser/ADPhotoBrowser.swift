//
//  ADPhotoBrowser.swift
//  MagicMoveTest01
//
//  Created by 李家斌 on 2018/9/11.
//  Copyright © 2018年 李家斌. All rights reserved.
//

import UIKit

class ADPhotoBrowser: UIViewController, UIViewControllerTransitioningDelegate {
    
    enum BROWSER_STATE: Int {
        case looping = 1    /// 图片浏览模式（默认）
        case paning = 2     /// 拖动模式
    }
    
    enum DISMISS_TYPE: Int {
        case tap = 1        /// 通过点击退出页面
        case swipe = 2      /// 通过向下扫动退出页面
    }
    
    private var state = BROWSER_STATE.looping {
        didSet {
            if state == .looping {
                print("looping")
                /// 如果paningImageView不为nil，则让他回到原地后销毁
                if paningImageView != nil {
                    // 执行动画
                    UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {[weak self]() -> Void in
                        self?.isAnimating = true
                        self?.paningImageView!.frame = (self?.getLoopViewCurrentImageFrame())!
                        self?.loopView!.backgroundColor = .black
                    }, completion: { [weak self](finish : Bool) -> Void in
                        guard finish == true else {
                            return
                        }
                        self?.isAnimating = false
                        self?.paningImageView!.removeFromSuperview()
                        self?.paningImageView = nil
                        self?.loopView?.currentShowImgView?.isHidden = false
                        self?.loopView?.currentShowPhotoView?.contentSize = CGSize(width: (self?.loopView?.currentShowImgView?.frame.width)!, height: (self?.loopView?.currentShowImgView?.frame.height)!)
                        
                        var offset: CGPoint?
                        let imgHeight = self?.loopView?.currentShowImgView?.frame.height
                        if isIPhoneX && imgHeight! >= UIScreen.main.bounds.height{
                            offset = CGPoint(x: 0, y: 0 - UIApplication.shared.statusBarFrame.height)
                        }else {
                            offset = CGPoint(x: 0, y: 0)
                        }
                        self?.loopView?.currentShowPhotoView?.setContentOffset(offset!, animated: false)
                    })
                }
            }
            if state == .paning {
                print("paning")
                guard self.loopView?.currentShowImgView?.image != nil else {
                    return
                }
                guard self.isAnimating == false else {
                    return
                }
                
                /// 生成一张拖动的图片
                
                paningImageView = UIImageView(frame: self.getLoopViewCurrentImageFrame())
                paningImageView!.contentMode = .scaleAspectFill
                paningImageView!.clipsToBounds = true
                paningImageView!.backgroundColor = .black
                paningImageView!.image = self.loopView!.currentShowImgView!.image!
                self.view.addSubview(paningImageView!)
                
                self.loopView?.currentShowImgView?.isHidden = true
            }
        }
    }
    
    /// 销毁的方式：单击销毁或者下扫销毁
    private var dismissType = DISMISS_TYPE.tap
    /// 来源View，主要用于获取来源的位置，产生一个缩放位移的进场动画
    private var fromView: UIImageView?
    /// 图片url集合
    private var imageList = NSArray()
    /// 当前展示第几张图
    private var currentIndex = 0
    
    /// 占位图
    private var placeholder = UIImage()
    /// 占位图集合
    private var placeholders = NSArray()
    /// 是否多张占位图
    private var isMultiPlaceholders = false
    
    /// 图片动画ing
    private var isAnimating = false
    /// touchBegin坐标
    private var startPoint: CGPoint?
    
    /// 当前显示图片缩放比例
    private var currentScale: CGFloat = 1
    
    /// ADLoopView
    var loopView: ADPhotoLoopView?
    /// 上一个页面的截图，在Controller完全显示后加入最后一层
    var lastView: UIView?
    /// 拖动的图片
    var paningImageView: UIImageView?
    /// 是否显示状态栏
    var isStatusBarHidden = false
    
    /// 初始化方法
    /// - parameter images          :图片URL集合
    /// - parameter currentIndex    :当前显示第几张
    /// - parameter placeholder     :占位图
    init(images: NSArray, fromView: UIImageView?, currentIndex: Int = 0, placeholder: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.imageList = images
        self.fromView = fromView
        self.currentIndex = currentIndex
        if placeholder != nil {
            self.placeholder = placeholder!
        }
    }
    
    /// 初始化方法
    /// - parameter images          :图片URL集合
    /// - parameter currentIndex    :当前显示第几张
    /// - parameter placeholders    :占位图集合
    init(images: NSArray, fromView: UIImageView?, currentIndex: Int = 0, placeholders: NSArray?) {
        super.init(nibName: nil, bundle: nil)
        self.imageList = images
        self.fromView = fromView
        self.currentIndex = currentIndex
        if placeholders != nil {
            self.placeholders = placeholders!
            self.isMultiPlaceholders = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.transitioningDelegate = self
        self.setUI()
        
        /// 添加监听通知，监听应用是否在此控制器中退出到后台，如果退出到后台，则动画停止，重制所有动画相关View和属性
        NotificationCenter.default.addObserver(self, selector: #selector(appHasGoneBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc func appHasGoneBackground(notification:NSNotification) {
        print("app进入后台")
        self.isAnimating = false
        if paningImageView != nil {
            self.paningImageView!.removeFromSuperview()
            self.paningImageView = nil
        }
        self.loopView?.currentShowImgView?.isHidden = false
    }

    private func setUI() {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        var loopView: ADPhotoLoopView?
        if isMultiPlaceholders {
            loopView = ADPhotoLoopView(frame: frame, images: self.imageList, currentIndex: self.currentIndex, placeholders: self.placeholders)
        }else {
            loopView = ADPhotoLoopView(frame: frame, images: self.imageList, currentIndex: self.currentIndex, placeholder: self.placeholder)
        }
        loopView!.delegate = self
        loopView!.loopContentMode = .scaleAspectFit
        loopView!.isHidden = true
        loopView!.backgroundColor = .black
        self.loopView = loopView
        view.addSubview(loopView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loopView!.isHidden = false
        
        if self.lastView != nil {
            self.view.insertSubview(self.lastView!, belowSubview: self.loopView!)
        }
        
        // 拖拽手势
        let panGestureDown = UIPanGestureRecognizer(target: self, action: #selector(respondToPanGesture))
        self.view.addGestureRecognizer(panGestureDown)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func respondToPanGesture(send: UIPanGestureRecognizer) {
        if send.state == .began {
            self.startPoint = send.location(in: self.view)
        }else if send.state == .changed {
            if send.translation(in: self.view).y > 0 {// 向下滑动
                if self.state == .looping {/// 上一个状态是looping，改变状态
                    self.state = .paning
                }else {// 上一个状态是paning，拖动图片
                    self.changeImageFrame(send: send)
                }
            }else {
                self.changeImageFrame(send: send)
            }
        }else if send.state == .ended {
            if send.velocity(in: self.view).y > 1000 {// 快速向下扫动，dismiss本类
                self.dismissType = .swipe
                self.dismiss(animated: true, completion: nil)
            }else {
                if self.state == .paning && self.isAnimating == false{
                    self.state = .looping
                }
            }
            print(send.velocity(in: self.view))
        }
    }
    
    /// 改变paningImageView图的位置
    func changeImageFrame(send: UIPanGestureRecognizer) {
        if self.paningImageView != nil {
            guard self.isAnimating == false else {
                return
            }
            
            guard self.startPoint != nil else {
                return
            }
            
            let movePoint = send.translation(in: self.view)
            let oriFrame = getLoopViewCurrentImageFrame()
            
            guard oriFrame.width != 0 else {
                return
            }
            
            var moveRatio = 1 - movePoint.y / UIScreen.main.bounds.size.height
            if moveRatio > 1 {
                moveRatio = 1
            }
            
            self.loopView!.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: moveRatio)
            
            // 宽度差
            let widthDifference = oriFrame.width - oriFrame.width * moveRatio
            // x点位移
            let xMove = widthDifference * (startPoint!.x / oriFrame.width)
            
            self.paningImageView?.frame = CGRect(x: oriFrame.origin.x + movePoint.x + xMove, y: oriFrame.origin.y + movePoint.y, width: oriFrame.width * moveRatio, height: oriFrame.height * moveRatio)
        }
    }
    
    /// 获取当前显示图片的CGRect
    func getLoopViewCurrentImageFrame() -> CGRect {
        let imgWidth = self.loopView!.currentShowImgView!.frame.width
        let imgHeight = self.loopView!.currentShowImgView!.frame.height
        let x = CGFloat(0) - self.loopView!.currentShowPhotoView!.contentOffset.x
        var y = self.loopView!.currentShowImgView!.frame.origin.y
        if isIPhoneX && imgHeight >= UIScreen.main.bounds.height {
            y = y + UIApplication.shared.statusBarFrame.height
        }
        
        let snapFrame = CGRect(x: x, y: y, width: imgWidth, height: imgHeight)
        return snapFrame
    }
    
    deinit {
        //移除通知
        NotificationCenter.default.removeObserver(self)
        print("ADPhotoBrowser销毁")
    }
}

/// ADLoopView代理方法
extension ADPhotoBrowser: ADPhotoLoopViewDelegate {
    /// 更新当前Index方法
    func adPhotoLoopViewWithCurrentIndex(adPhotoLoopView: ADPhotoLoopView, currentIndex: NSInteger) {
        self.currentIndex = currentIndex
    }
    
    /// 单击图片
    func adPhotoLoopView(adPhotoLoopView: ADPhotoLoopView, index: NSInteger) {
        print("点击了第\(index)张图片")
        guard self.isAnimating == false else {
            return
        }
        self.dismissType = .tap
        self.dismiss(animated: true, completion: nil)
    }
}

extension ADPhotoBrowser {
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ADImageBrowseTransion(fromView: self.fromView)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if isMultiPlaceholders {
            return ADImageBrowsePopTransion(dismissType: self.dismissType.rawValue, fromView: self.placeholders[currentIndex] as? UIImageView)
        }else {
            return ADImageBrowsePopTransion(dismissType: self.dismissType.rawValue, fromView: self.fromView)
        }
    }
}
