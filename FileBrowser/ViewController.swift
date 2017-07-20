//
//  ViewController.swift
//  FileBrowser
//
//  Created by 서창열 on 2017. 7. 20..
//  Copyright © 2017년 서창열. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GNFileBrowserDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTouchupBtn(_ sender: Any) {
        let controller = GNFileBrowser.viewController
        controller.fileBrowserDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func gnfilebrowser(pickup file: [GNFile]) {
        
        
    }
}

