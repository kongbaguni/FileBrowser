//
//  GNFileBrowserFileTableViewCell.swift
//  FileBrowser
//
//  Created by 서창열 on 2017. 7. 20..
//  Copyright © 2017년 서창열. All rights reserved.
//

import Foundation
import UIKit
class GNFileBrowserFileTableViewCell: UITableViewCell {
    var thumbImageSize:CGSize = CGSize(width: 50, height: 50)
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var timeLabel: UILabel!
    func loadData(_ file:GNFile) {
        label.text = "\(file.name)"
        if let date = file.creationDate {
            timeLabel.text = date.toUtcString("yyyy-MM-dd ah:mm")
        }
        if let image = file.thumbImage(thumbImageSize) {
            iconView.image = image
        }
        else {
            switch file.fileType {
            case .Directory:
                iconView.image = #imageLiteral(resourceName: "Folder-icon")
            default:
                iconView.image = #imageLiteral(resourceName: "icon_view_01_doc")
            }
        }
        
    }
    
    
}
