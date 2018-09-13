//
//  ViewController.swift
//  ADPhotoBrowserDemo
//
//  Created by 李家斌 on 2018/9/13.
//  Copyright © 2018年 李家斌. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loopView: UIScrollView!
    
    var placeholders = NSMutableArray()
    
    // 本地缩略图
    let localSmallImgs = NSArray(array: ["little_img_1",
                                         "little_img_2",
                                         "little_img_3",
                                         "little_img_4",
                                         "little_img_5",
                                         "little_img_6",
                                         "little_img_7"])
    
    // 网络图片
    let imagesWeb = NSArray(array: [
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1536569709794&di=942c0f04efb9dfdf7fcddef23d37dce6&imgtype=0&src=http%3A%2F%2Fbangimg1.dahe.cn%2Fforum%2Fpw%2FMon_1112%2F445_517996_04e69d1be28b439.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1536138710020&di=ff98e17de2ab7c3088182b4a227f8dac&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fwallpaper%2F1408%2F28%2Fc1%2F37950569_1409156831122_800x800.jpg",
        "http://i.imgur.com/w5rkSIj.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1536138767193&di=5be964c456d7abbd7d4ea68bb112c49d&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fwallpaper%2F1606%2F30%2Fc3%2F23589301_1467290861869_800x800.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1536733512&di=691993f345083ac8bb79ab19ce71a50b&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fwallpaper%2F1601%2F31%2Fc0%2F18075531_1454249261384_800x800.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1536138810236&di=0b993858f7bd97cd8bc7284c7db7a064&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fwallpaper%2F1606%2F30%2Fc2%2F23579206_1467279001712_800x800.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1536834646661&di=438e35858a35ee9b83473d59a1f46528&imgtype=0&src=http%3A%2F%2Fimg18.house365.com%2Fnewcms%2F2017%2F04%2F27%2F149327846159019efdde2e7.jpg"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11, *)  {
            self.loopView.contentInsetAdjustmentBehavior = .never
        }else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.loopView.contentSize = CGSize(width: 80 * localSmallImgs.count, height: 0)
        
        for i in 0..<localSmallImgs.count {
            let imgView = UIImageView(frame: CGRect(x: 80 * i, y: 0, width: 80, height: 80))
            imgView.image = UIImage(named: localSmallImgs[i] as! String)
            imgView.contentMode = .scaleAspectFill
            imgView.isUserInteractionEnabled = true
            imgView.tag = 1000 + i
            
            placeholders.add(imgView)
            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(viewPhotoTap))
            imgView.addGestureRecognizer(singleTap)
            
            self.loopView.addSubview(imgView)
        }
    }

    @objc func viewPhotoTap(sender: UITapGestureRecognizer) {
        let adpb = ADPhotoBrowser(images: imagesWeb, fromView: sender.view as? UIImageView, currentIndex: (sender.view?.tag)! - 1000, placeholders: NSArray(array: placeholders))
        self.present(adpb, animated: true, completion: nil)
        
    }


}

