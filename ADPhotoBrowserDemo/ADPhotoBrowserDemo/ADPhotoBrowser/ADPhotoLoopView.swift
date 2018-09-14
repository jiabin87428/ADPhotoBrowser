//
//  ADPhotoLoopView.swift
//  MagicMoveTest01
//
//  Created by 李家斌 on 2018/9/12.
//  Copyright © 2018年 李家斌. All rights reserved.
//

import UIKit

class ADPhotoLoopView: UIView {
    /// 分页控件位置
    enum PAGECONTROL_POSITION: Int {
        case left = 1
        case center = 2
        case right = 3
    }
    
    /// ADPhotoLoopView代理
    weak var delegate: ADPhotoLoopViewDelegate?
    /// 当前显示的ADPhotoView
    var currentShowPhotoView: ADPhotoView?
    /// 当前显示的ImageView
    var currentShowImgView: UIImageView?
    /// 图片显示模式
    var loopContentMode = UIViewContentMode.scaleAspectFill
    
    // MARK: 私有属性
    
    /// 分页控制器
    private var pageControl : ADPageControl?
    /// ScrollView
    private var loopView : UIScrollView?
    
    /// 占位图
    private var placeholder = UIImage()
    /// 占位图集合
    private var placeholders = NSArray()
    /// 是否多张占位图
    private var isMultiPlaceholders = false
    
    /// 当前展示序号
    private var currentPage = 0
    
    /// 展示图片URL列表
    private var imageList : NSArray?
    
    /// 初始化高度
    private var initHeight: CGFloat = 0.0
    
    /// NSLock锁对象
    private var lock = NSLock()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初始化方法
    /// - parameter frame           :组件尺寸
    /// - parameter images          :展示图片URL集合
    /// - parameter placeholder     :占位图
    /// - parameter currentIndex    :当前展示页
    convenience init(frame: CGRect, images: NSArray, currentIndex: Int = 0, placeholder: UIImage?) {
        self.init(frame: frame)
        self.imageList = images
        self.currentPage = currentIndex
        if placeholder != nil {
            self.placeholder = placeholder!
        }
        self.initSetting()
    }
    
    /// 初始化方法
    /// - parameter frame           :组件尺寸
    /// - parameter images          :展示图片URL集合
    /// - parameter placeholders    :占位图集合
    /// - parameter currentIndex    :当前展示页
    convenience init(frame: CGRect, images: NSArray, currentIndex: Int = 0, placeholders: NSArray?) {
        self.init(frame: frame)
        self.imageList = images
        self.currentPage = currentIndex
        if placeholders != nil {
            self.placeholders = placeholders!
            self.isMultiPlaceholders = true
        }
        self.initSetting()
    }
    
    /// 初始化设置
    private func initSetting() {
        self.backgroundColor = .clear
        self.initHeight = self.frame.height
        createLoopView()
        createPageControl()
        
        if #available(iOS 11, *), !isIPhoneX  {
            self.loopView!.contentInsetAdjustmentBehavior = .never
        }
        
        if self.imageList!.count<2{
            pageControl?.isHidden = true
        }
    }
    
    // 创建ScrollerVIew
    private func createLoopView() {
        if imageList?.count == 0 {
            return
        }
        loopView = UIScrollView(frame: self.bounds)
        loopView?.backgroundColor = .clear
        loopView?.showsHorizontalScrollIndicator = false
        loopView?.showsVerticalScrollIndicator = false
        loopView?.bounces = true
        loopView?.delegate = self
        loopView?.contentSize = CGSize(width: self.bounds.width * CGFloat(self.imageList!.count), height: 0)
        loopView?.isPagingEnabled = true
        self.addSubview(loopView!)
        
        for i in 0..<self.imageList!.count {
            var phImage: UIImage?
            if isMultiPlaceholders {// 如果是多张占位图
                phImage = (self.placeholders[i] as? UIImageView)?.image
            }else {// 如果是单张占位图
                phImage = self.placeholder
            }
            let adImg = ADPhotoView(frame: CGRect(x: self.bounds.width * CGFloat(i), y: 0, width: self.bounds.width, height: self.bounds.height), url: self.imageList![i] as! String, placeholder: phImage)
            adImg.adPhotoDelegate = self
            loopView?.addSubview(adImg)
        }
        refreshImages()
    }
    
    // 创建PageController
    private func createPageControl() {
        if imageList?.count == 0 {
            return
        }
        
        pageControl = ADPageControl(frame: CGRect(x: 0, y: self.bounds.height - 50, width: self.bounds.width, height: 30))
        pageControl?.numberOfPages = imageList!.count
        pageControl?.currentPage = currentPage
        pageControl?.isUserInteractionEnabled = false
        self.addSubview(pageControl!)
        pageControl?.pagePosition = .center
    }
    
    // 每次图片滚动时刷新图片
    private func refreshImages() {
        self.loopView?.contentOffset = CGPoint(x: self.bounds.width * CGFloat(self.currentPage), y: 0)
        self.currentShowImgView = (loopView!.subviews[currentPage] as? ADPhotoView)?.adImageView
        self.currentShowPhotoView = loopView!.subviews[currentPage] as? ADPhotoView
        
        if self.delegate != nil && self.delegate!.responds(to: #selector(ADPhotoLoopViewDelegate.adPhotoLoopViewWithCurrentIndex(adPhotoLoopView:currentIndex:))) {
            self.delegate?.adPhotoLoopViewWithCurrentIndex!(adPhotoLoopView: self, currentIndex: currentPage)
        }
    }
}

// MARK: UIScrollerView代理方法
extension ADPhotoLoopView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / self.bounds.width)
        pageControl!.currentPage = currentPage
        refreshImages()
    }
}

extension ADPhotoLoopView: ADPhotoViewDelegate {
    func adPhotoView(adPhotoView: ADPhotoView, view: UIImageView) {
        if self.delegate != nil && self.delegate!.responds(to: #selector(ADPhotoLoopViewDelegate.adPhotoLoopView(adPhotoLoopView:index:))) {
            self.delegate?.adPhotoLoopView!(adPhotoLoopView: self, index: currentPage)
        }
    }
}

// MARK: ADPhotoLoopView代理方法
@objc protocol ADPhotoLoopViewDelegate : NSObjectProtocol {
    @objc optional
    // 点击图片事件
    func adPhotoLoopView(adPhotoLoopView: ADPhotoLoopView ,index: NSInteger)
    @objc optional
    // 更新当前页方法
    func adPhotoLoopViewWithCurrentIndex(adPhotoLoopView: ADPhotoLoopView ,currentIndex: NSInteger)
}
