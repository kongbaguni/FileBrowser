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
    //파일 선택 제한. 0은 무제한입니다.
    var limitFileSelect:Int = 0
    //검색창 placeHolder 정의
    var searchBarPlaceHolder:String = "search".localized
        
    var selectedFiles:[GNFile] = []
    var fileBrowserDelegate:GNFileBrowserDelegate? = nil
    static var viewController:GNFileBrowser {
        return UIStoryboard(name: "GNFileBrowser", bundle: nil).instantiateViewController(withIdentifier: "main") as! GNFileBrowser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.onTouchUPCancelBtn(_:)))
        navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName:CM().color(ColorManager.ColorType.navigationTitleText),
             NSFontAttributeName:UIFont.boldSystemFont(ofSize: 20)]
        navigationBar.tintColor = CM().color(ColorManager.ColorType.navigationButtonText)
        setDefaultStyle()
    }
    
    
    func setRightButton() {
        if selectedFiles.count > 0 {
            navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "done".localized, style: .plain, target: self, action: #selector(self.onTouchUPDoneBtn(_:)))
        } else {
            navigationBar.topItem?.rightBarButtonItem = nil
        }
    }
    
    func onTouchUPCancelBtn(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    func onTouchUPDoneBtn(_ sender:UIBarButtonItem) {
        fileBrowserDelegate?.gnfilebrowser(pickup: selectedFiles)
        dismiss(animated: true, completion: nil)
    }
    
}
