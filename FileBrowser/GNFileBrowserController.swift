//
//  GNFileBrowserController.swift
//  GNFileBrowser
//
//  Created by 서창열 on 2017. 7. 20..
//  Copyright © 2017년 서창열. All rights reserved.
//

import Foundation
import UIKit


class GNFileBrowserController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var delegate:GNFileBrowserDelegate? {
        return (self.navigationController as? GNFileBrowser)?.fileBrowserDelegate
    }
    
    static var viewController:GNFileBrowserController {
        return UIStoryboard(name: "GNFileBrowser", bundle: nil).instantiateViewController(withIdentifier: "browser") as! GNFileBrowserController
    }
    var fileBrowser:GNFileBrowser? {
        if let vc = navigationController as? GNFileBrowser {
            return vc
        }
        return nil
    }
    
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchBar:UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContents()
        tableView.dataSource = self
        tableView.delegate = self
        title = "보관함"
        if let d = currentDirectory {
            title = d
        }
    }
    var fileList:[GNFile] = []
    var directorys:[GNFile] = []
    
    var documentPath:String? {
        if let url = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first {
            if let d = subDirectory {
                return "\(url.relativePath)/\(d)"
            }
            return url.relativePath
        }
        return nil
    }
    var subDirectory:String? = nil
    var currentDirectory:String? = nil
    func getContents() {
        do {
            guard let documentPath = self.documentPath else {
                return
            }
            fileList.removeAll()
            directorys.removeAll()
            let list = try FileManager.default.contentsOfDirectory(atPath: documentPath)
            debugPrint("------")
            debugPrint(list)
            for filename in list {
                debugPrint("------")
                let attributes = try FileManager.default.attributesOfItem(atPath:"\(documentPath)/\(filename)")
                debugPrint(attributes)
                debugPrint("------")
                let date = attributes[FileAttributeKey.creationDate] as? Date
                let type = attributes[FileAttributeKey.type] as! String
                let file = GNFile()
                file.name = filename
                file.creationDate = date
                file.type = type
                switch file.fileType {
                case .File:
                    fileList.append(file)
                case .Directory:
                    directorys.append(file)
                }
                debugPrint("------")
            }
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK:TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyView.isHidden = directorys.count > 0 || fileList.count > 0
        tableView.isHidden = !emptyView.isHidden
        switch section {
        case 0:
            return directorys.count
        default:
            return fileList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "file", for: indexPath) as! GNFileBrowserFileTableViewCell
            cell.loadData(directorys[indexPath.row])
            return cell
        default:
            var identifire = "file"
            let file = fileList[indexPath.row]
            if let files = fileBrowser?.selectedFiles {
                if let _ = files.index(of: file) {
                    identifire = "fileSelect"
                }
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: identifire, for: indexPath) as! GNFileBrowserFileTableViewCell
            cell.loadData(file)
            return cell
        }
    }
    
    //MARK:TableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let file = directorys[indexPath.row]
            let vc = GNFileBrowserController.viewController
            if let sub = self.subDirectory {
                vc.subDirectory = "\(sub)/\(file.name)"
            }
            else {
                vc.subDirectory = file.name
            }
            vc.currentDirectory = file.name
            navigationController?.pushViewController(vc, animated: true)
        default:
            let file = fileList[indexPath.row]
            if let files = fileBrowser?.selectedFiles {
                if let idx = files.index(of: file) {
                    fileBrowser?.selectedFiles.remove(at: idx)
                }
                else {
                    fileBrowser?.selectedFiles.append(file)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            print(file.name)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if directorys.count == 0 {
                return nil
            }
            return "Directorys"
        default:
            if fileList.count == 0 {
                return nil
            }
            return "Files"
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if directorys.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 30
        default:
            if fileList.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 30
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var file:GNFile!
        switch indexPath.section {
        case 0:
            file = directorys[indexPath.row]
        default:
            file = fileList[indexPath.row]
        }
        
        var actions:[UITableViewRowAction] = []
        actions.append(UITableViewRowAction(style: .default, title: "delete", handler: { (action, indexPath) in
            
        }))
        
        actions.append(UITableViewRowAction(style: .normal, title: "rename", handler: { (action, indexPath) in
            let vc = UIAlertController(title: "rename", message: nil, preferredStyle: .alert)
            vc.addTextField(configurationHandler: { (textField) in
                textField.text = file.name
            })
            vc.addAction(UIAlertAction(title: "confirm", style: .default, handler: { (action) in
                guard let newName = vc.textFields?.first?.text ,
                let documentPath = self.documentPath
                else {
                    return
                }
                do {
                    try FileManager.default.moveItem(atPath: "\(documentPath)/\(file.name)", toPath: "\(documentPath)/\(newName)")
                } catch {
                    print(error.localizedDescription)
                }
                self.getContents()
                self.tableView.reloadData()
            }))
            vc.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            self.present(vc, animated: true, completion: nil)
            
        }))
        return actions
    }
}
