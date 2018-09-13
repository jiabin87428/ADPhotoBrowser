//
//  ADPhotoView.swift
//  MagicMoveTest01
//
//  Created by 李家斌 on 2018/9/12.
//  Copyright © 2018年 李家斌. All rights reserved.
//

import UIKit


class ADPhotoView: UIScrollView {
    weak var adPhotoDelegate: ADPhotoViewDelegate?
    /// 显示图片
    var adImageView: UIImageView?
    
    /// URL String
    private var imageUrl = ""
    /// 占位图
    private var placeholder = UIImage()
    
    private var lastContentOffset: CGFloat = 0
    private var lastPoint: CGPoint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, url: String, placeholder: UIImage? = nil) {
        self.init(frame: frame)
        self.imageUrl = url
        if placeholder != nil {
            self.placeholder = placeholder!
        }
        
        self.initSetting()
    }
    
    /// 初始化设置
    private func initSetting() {
        self.backgroundColor = .clear
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.bounces = true
        self.delegate = self
        self.isPagingEnabled = false

        self.maximumZoomScale = 5
        self.minimumZoomScale = 1
        
        createImage()
    }
    
    // 创建图片数据
    private func createImage() {
        let imgView = UIImageView()
        imgView.image = self.placeholder
        imgView.isUserInteractionEnabled = true
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.frame = self.getLoopViewCurrentImageFrame(image: self.placeholder)
        self.adImageView = imgView
        
        self.contentSize = CGSize(width: imgView.frame.width, height: imgView.frame.height)
        
        self.addSubview(imgView)
        
        let singleClick = UITapGestureRecognizer(target: self, action: #selector(singleClickToDismiss))
        imgView.addGestureRecognizer(singleClick)
        
        let doubleClick = UITapGestureRecognizer(target: self, action: #selector(doubleClickToScale))
        doubleClick.numberOfTapsRequired = 2
        imgView.addGestureRecognizer(doubleClick)
        
        singleClick.require(toFail: doubleClick)
        
        if imageUrl == "" {
            return
        }
        if imageUrl.hasPrefix("http") {// 图片来自网络
            self.loadWebImage(url: imageUrl)
        }else {// 图片来自本地
            let localImg = UIImage(named: imageUrl)
            self.adImageView?.image = localImg
        }
    }
    
    // 单击图片
    @objc func singleClickToDismiss(tap: UITapGestureRecognizer) {
        if self.adPhotoDelegate != nil && self.adPhotoDelegate!.responds(to: #selector(ADPhotoViewDelegate.adPhotoView(adPhotoView:view:))) {
            self.adPhotoDelegate?.adPhotoView!(adPhotoView: self, view: self.adImageView!)
            
        }
    }
    
    // 双击图片
    @objc func doubleClickToScale(tap: UITapGestureRecognizer) {
        var zoomScale = self.zoomScale
        zoomScale = zoomScale == 1.0 ? 2.5 : 1.0
        let zoomRect = self.zoomRectForScale(scale: zoomScale, center: tap.location(in: tap.view))
        self.zoom(to: zoomRect, animated: true)
    }
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        let width = self.frame.size.width  / scale
        let height = self.frame.size.height / scale
        let x = center.x - (width  / 2.0)
        let y = center.y - (height / 2.0)
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

// MARK: 工具方法
extension ADPhotoView {
    /// 异步加载图片
    /// - parameter url             :网络图片地址
    /// - parameter placeholder     :占位图
    private func loadWebImage(url: String?) {
        if url == nil{
            return
        }
        
        /// 全局队列异步执行
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            let imgUrl = URL(string: url!)
            let imgData = try? Data(contentsOf: imgUrl!)
            if imgData != nil {
                DispatchQueue.main.async {[weak self] in
                    self?.adImageView?.image = UIImage(data: imgData!)
                }
            }
        }
    }
    
    /// 获取当前显示图片的CGRect
    private func getLoopViewCurrentImageFrame(image: UIImage) -> CGRect {
        let imgWidth = UIScreen.main.bounds.size.width
        let imgHeight = (image.size.height * imgWidth) / image.size.width
        let y = (UIScreen.main.bounds.size.height - imgHeight) / 2
        
        let snapFrame = CGRect(x: 0, y: y < 0 ? 0 : y, width: imgWidth, height: imgHeight)
        return snapFrame
    }
}

extension ADPhotoView: UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.contentOffset.y < 0 {
            return true
        }else {
            return false
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.adImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.0
        if scrollView.bounds.size.width > scrollView.contentSize.width {
            offsetX = (scrollView.bounds.size.width - scrollView.contentSize.width) / 2
        }
        
        if scrollView.bounds.size.height > scrollView.contentSize.height {
            offsetY = (scrollView.bounds.size.height - scrollView.contentSize.height) / 2
        }
        
        self.adImageView?.center = CGPoint(x: scrollView.contentSize.width/2 + offsetX, y: scrollView.contentSize.height/2 + offsetY)
    }
}

// MARK: ADPhotoView代理方法
@objc protocol ADPhotoViewDelegate : NSObjectProtocol {
    @objc optional
    // 点击图片事件
    func adPhotoView(adPhotoView: ADPhotoView ,view: UIImageView)
}
