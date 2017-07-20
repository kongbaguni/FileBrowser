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
    var data:Data? {
        if FileManager.default.fileExists(atPath: path) == false {
            return nil
        }
        if let url = URL(string:path) {
            do {
                return try Data(contentsOf: url)
            }
            catch {
                print(error.localizedDescription)
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
}
