//
//  GNFile.swift
//  FileBrowser
//
//  Created by 서창열 on 2017. 7. 20..
//  Copyright © 2017년 서창열. All rights reserved.
//

import Foundation
class GNFile: NSObject {
    enum FileType {
        case File
        case Directory
    }
    var name:String = ""
    var creationDate:Date? = nil
    var type:String = ""
    
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
}
