//
//  GNFileBrowser.swift
//  FileBrowser
//
//  Created by 서창열 on 2017. 7. 20..
//  Copyright © 2017년 서창열. All rights reserved.
//

import Foundation
import UIKit

class GNFileBrowser : UINavigationController {
    var selectedFiles:[GNFile] = []
    var fileBrowserDelegate:GNFileBrowserDelegate? = nil
    static var viewController:GNFileBrowser {
        return UIStoryboard(name: "GNFileBrowser", bundle: nil).instantiateViewController(withIdentifier: "main") as! GNFileBrowser
    }
    
    override func viewDidLoad() {
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.onTouchUPCancelBtn(_:)))
        
    }
    
    func onTouchUPCancelBtn(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
