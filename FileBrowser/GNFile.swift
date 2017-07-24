//
//  GNFile.swift
//  FileBrowser
//
//  Created by 서창열 on 2017. 7. 20..
//  Copyright © 2017년 서창열. All rights reserved.
//

import Foundation
import UIKit
class GNFile: NSObject {
    enum FileType {
        case File
        case Directory
    }
    var size:Int = 0
    var name:String = ""
    var creationDate:Date? = nil
    var type:String = ""
    var path:String = ""
    var fileType:FileType {
        switch type {
        case "NSFileTypeRegular":
            return .File
        case "NSFileTypeDirectory":
            return .Directory
        default:
            break
        }
        return .File
    }
    var url:URL? {
        return Bundle.main.url(forAuxiliaryExecutable: path)
    }
    var data:Data? {
        if FileManager.default.fileExists(atPath: path) == false {
            return nil
        }
        if let url = self.url {
            do {
                let d =  try Data(contentsOf: url)
                return d
            }
            catch {
                
            }
        }
        return nil
    }
    override var hashValue:Int {
        if let d = self.data {
            return d.hashValue
        }
        return 0
    }
    
    var image:UIImage? {
        if let image = UIImage(contentsOfFile: path) {
            return image
        }
        if let data = self.data {
            return UIImage(data: data)
        }
        return nil
    }
    
    func thumbImage(_ size:CGSize) -> UIImage? {
        if let image = self.image {
            return image.resizeImage(size)
        }

        if let ext = name.lowercased().components(separatedBy: ".").last {
            switch ext {
            case "doc":
                return #imageLiteral(resourceName: "icon_view_01_doc")
                //비디오
            case "mp4", "mpeg", "mpg","avi", "mov", "rm", "vob", "asx", "mmp":
                return #imageLiteral(resourceName: "icon_view_02_avi")
                //오디오
            case "mp2","mp3","wav","flac","wma","aac","ac3","m3u","ogg", "ra", "ram", "vob", "voc":
                return #imageLiteral(resourceName: "icon_view_03_mp3")
                //문서
            case "doc", "odt", "gdoc":
                return #imageLiteral(resourceName: "icon_view_04_word")
                //스프레트시트
            case "xlsx", "pxl", "xlc", "xls", "xlt", "ods", "gsheet":
                return #imageLiteral(resourceName: "icon_view_05_excel")
                //프레젠테이션
            case "pptx", "ppt", "pot", "pps", "ppv", "odp":
                return #imageLiteral(resourceName: "icon_view_06_ppt")
            default:
                break
                
            }
        }
        return nil
    }
}
