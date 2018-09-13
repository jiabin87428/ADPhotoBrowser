//
//  ADPageControl.swift
//  ADPhotoBrowserDemo
//
//  Created by 李家斌 on 2018/9/13.
//  Copyright © 2018年 李家斌. All rights reserved.
//

import UIKit

/// 分页点宽度
private var dotW: CGFloat = 7.0
/// 分页点高度
private var dotH: CGFloat = 7.0
/// 分页点间隔
private var margin: CGFloat = 4.0

class ADPageControl: UIPageControl {
    /// 分页控件位置
    enum PAGECONTROL_POSITION: Int {
        case left = 1
        case center = 2
        case right = 3
    }
    
    // MARK: 共有属性
    /// 分页控件位置 默认.center
    /// - parameter .left   :居左
    /// - parameter .center :居中
    /// - parameter .right  :居右
    var pagePosition = PAGECONTROL_POSITION.center {
        didSet{
            let marginX = margin + dotW
            let newW: CGFloat = CGFloat(self.subviews.count) * marginX - margin
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newW, height: self.frame.size.height)
            if pagePosition == .left{
                self.frame = CGRect(x: 10, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
            }
            if pagePosition == .center{
                var center = self.center
                center.x = self.center.x
                self.center = center
            }
            if pagePosition == .right{
                self.frame = CGRect(x: self.frame.width - self.frame.width - 10, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let marginX = margin + dotW
        
        for i in 0..<self.subviews.count {
            let dot = self.subviews[i]
            dot.frame = CGRect(x: CGFloat(i) * marginX, y: dot.frame.origin.y, width: CGFloat(dotW), height: CGFloat(dotH))
        }
    }
    
    /// 设置分页的图标
    /// - parameter pageImage           :分页图
    /// - parameter currentPageImage    :当前分页图
    /// - parameter dotWidth            :分页点宽度 默认20
    /// - parameter dotHeight           :分页点高度 默认3
    /// - parameter dotMargin           :分页点间隔 默认5
    func setPageImge(pageImage: String, currentPageImage: String, dotWidth: CGFloat = 20.0, dotHeight: CGFloat = 3.0, dotMargin: CGFloat = 5.0) {
        let pageImg = UIImage(named: pageImage)
        let currentPageImg = UIImage(named: currentPageImage)
        dotW = dotWidth
        dotH = dotHeight
        margin = dotMargin
        self.pagePosition = PAGECONTROL_POSITION(rawValue: self.pagePosition.rawValue)!
        self.setNeedsLayout()
        
        // 一定要两个图片都正确才能成功赋值
        if pageImg != nil && currentPageImg != nil{
            self.setValue(UIImage(named: pageImage), forKey: "_pageImage")
            self.setValue(UIImage(named: currentPageImage), forKey: "_currentPageImage")
        }
    }
}
