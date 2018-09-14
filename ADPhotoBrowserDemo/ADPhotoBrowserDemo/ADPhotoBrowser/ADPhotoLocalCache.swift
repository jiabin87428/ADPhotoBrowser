//
//  ADPhotoLocalCache.swift
//  ADPhotoBrowserDemo
//
//  Created by 李家斌 on 2018/9/14.
//  Copyright © 2018年 李家斌. All rights reserved.
//

import UIKit

class ADPhotoLocalCache {
    // 写入照片
    class func writePhoto(fileName: String, data: Data) -> Bool {
        let adPhotoPath:String = NSHomeDirectory() + "/Documents/" + "ADPhotoCache/"
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: adPhotoPath){// 文件夹不存在，先创建文件夹
            do {
                //withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
                try fileManager.createDirectory(atPath: adPhotoPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        }
        
        let imagePath = adPhotoPath + getImageName(filePath: fileName)
        
        do {
            try data.write(to: URL(fileURLWithPath: imagePath))
            return true
        } catch let error  {
            print(error.localizedDescription)
            return false
        }
    }
    
    // 读取照片
    class func getPhoto(fileName: String) -> Data? {
        return getPhotoFromLocal(fileName: fileName)
    }
    
    // 通过缓存查找
    private class func getPhotoFromCache() {
        
    }
    
    // 通过本地查找
    private class func getPhotoFromLocal(fileName: String) -> Data? {
        let fileManager = FileManager.default
        let imageName = getImageName(filePath: fileName)
        let urlsForDocDirectory = fileManager.urls(for: .documentDirectory, in:.userDomainMask)
        let docPath = urlsForDocDirectory[0]
        let file = docPath.appendingPathComponent("ADPhotoCache/" + imageName)
        
        do {
            let readHandler = try FileHandle(forReadingFrom:file)
            let data = readHandler.readDataToEndOfFile()
            return data
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// 通过图片URL计算得出一个35位的图片名，再去本地找
    private class func getImageName(filePath: String) -> String {
        // url过长，不能写入，先转一下Base64
        let utf8EncodeData = filePath.data(using: String.Encoding.utf8, allowLossyConversion: true)
        // 将NSData进行Base64编码
        var base64String = utf8EncodeData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0)))
        base64String = base64String?.replacingOccurrences(of: "=", with: "")
        base64String = base64String?.replacingOccurrences(of: "+", with: "")
        base64String = base64String?.replacingOccurrences(of: "/", with: "")
        
        // 取前15位+后20位作为图片名
        return base64String!.prefix(15) + base64String!.suffix(20) + ".png"
    }
}
