//
//  GNFileBrowserController.swift
//  GNFileBrowser
//
//  Created by 서창열 on 2017. 7. 20..
//  Copyright © 2017년 서창열. All rights reserved.
//

import Foundation
import UIKit


class GNFileBrowserController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate , UIGestureRecognizerDelegate {
    
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
    @IBOutlet var emptyViewLabel: UILabel!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchBar:UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContents()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        title = "locker".localized
        if let d = currentDirectory {
            title = d
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTapBG(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        tableView.addSubview(emptyView)
        searchBar.frame.size.height = 40
//        emptyView.frame.size.height = tableView.frame.height - searchBar.frame.height
        
        if searchBar.text == "" && directorys.count == 0 && fileList.count == 0 {
            searchBar.isHidden = true
        }
        checkEmptyViewHidden()
        setSearchBarPlaceHolder()
        searchBar.setOitalkStyle()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fileBrowser?.setRightButton()
        navigationController?.setDefaultStyle()
    }
    
    
    var _fileList:[GNFile] = []
    var fileList:[GNFile] {
        set {
            _fileList = newValue
        }
        get {
            if let searchText = searchBar.text {
                if searchText.isEmpty == false {
                    return _fileList.filter({ (file) -> Bool in
                        return file.name.lowercased().contains(searchText.lowercased())
                    })
                }
            }
            return _fileList
        }
    }
    
    var _directorys:[GNFile] = []
    var directorys:[GNFile] {
        set {
            _directorys = newValue
        }
        get {
            if let searchText = searchBar.text {
                if searchText.isEmpty == false {
                    return _directorys.filter({ (file) -> Bool in
                        return file.name.lowercased().contains(searchText.lowercased())
                    })
                }
            }
            return _directorys
        }
    }
    
    
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
            for filename in list {
                let attributes = try FileManager.default.attributesOfItem(atPath:"\(documentPath)/\(filename)")
                let file = GNFile()
                file.name = filename
                file.creationDate = attributes[FileAttributeKey.creationDate] as? Date
                file.type = attributes[FileAttributeKey.type] as! String
                file.path = "\(documentPath)/\(filename)"
                file.size = attributes[FileAttributeKey.size] as! Int
                switch file.fileType {
                case .File:
                    fileList.append(file)
                case .Directory:
                    directorys.append(file)
                }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "directory", for: indexPath) as! GNFileBrowserFileTableViewCell
            cell.loadData(directorys[indexPath.row])
            return cell
        default:
            var identifire = "file"
            let file = fileList[indexPath.row]
            if let files = fileBrowser?.selectedFiles {
                if let _ =
                    files.index(where: { (inFile) -> Bool in
                        return inFile.path == file.path
                    }) {
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
        guard let fileBrowser = self.fileBrowser else {
            return
        }
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
            DispatchQueue.main.async {
                let file = self.fileList[indexPath.row]
                if let files = self.fileBrowser?.selectedFiles {
                    if let idx =
                        files.index(where: { (inFile) -> Bool in
                            return inFile.path == file.path
                        }) {
                        self.fileBrowser?.selectedFiles.remove(at: idx)
                    }
                    else {
                        if fileBrowser.limitFileSelect > 0 {
                            if fileBrowser.selectedFiles.count >= fileBrowser.limitFileSelect {
                                return
                            }
                        }                        
                        self.fileBrowser?.selectedFiles.append(file)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        self.fileBrowser?.setRightButton()
                    }
                }
                
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if directorys.count == 0 {
                return nil
            }
            return "Directorys".localized
        default:
            if fileList.count == 0 {
                return nil
            }
            return "Files".localized
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
        actions.append(UITableViewRowAction(style: .default, title: "delete".localized, handler: { (action, indexPath) in
            let vc = UIAlertController(title: "file delete".localized, message: "file delete message".localized, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (action) in
                do {
                    try FileManager.default.removeItem(atPath: file.path)
                    if let idx = self._fileList.index(of: file) {
                        self._fileList.remove(at: idx)
                        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                    }
                    if let idx = self._directorys.index(of: file) {
                        self._directorys.remove(at: idx)
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                    }
                    if let list = self.fileBrowser?.selectedFiles {
                        if let idx = list.index(of: file) {
                            self.fileBrowser?.selectedFiles.remove(at: idx)
                            self.fileBrowser?.setRightButton()
                        }
                    }
                    
                }
                catch {
                    Toast.makeToast(error.localizedDescription)
                }
            }))
            vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            self.present(vc, animated: true, completion: nil)
        }))
        
        actions.append(UITableViewRowAction(style: .normal, title: "change".localized, handler: { (action, indexPath) in
            let vc = UIAlertController(title: "file rename".localized, message: nil, preferredStyle: .alert)
            vc.addTextField(configurationHandler: { (textField) in
                textField.text = file.name
            })
            vc.addAction(UIAlertAction(title: "confirm", style: .default, handler: { (action) in
                guard let newName = vc.textFields?.first?.text ,
                let documentPath = self.documentPath
                else {
                    return
                }
                if newName.isEmpty {
                    return
                }
                do {
                    try FileManager.default.moveItem(atPath: "\(documentPath)/\(file.name)", toPath: "\(documentPath)/\(newName)")
                } catch {
                    print(error.localizedDescription)
                }
                file.name = newName
                file.path = "\(documentPath)/\(newName)"
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }))
            vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            self.present(vc, animated: true, completion: nil)
            
        }))
        return actions
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y < -150 {
            dismiss(animated: true, completion: nil)
        }
    }
    //UIGestureDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return searchBar.isFirstResponder
    }
    
    
    //SearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        checkEmptyViewHidden()
        tableView.reloadData()
    }
    func onTapBG(_ gesture:UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    private func checkEmptyViewHidden() {
        emptyView.isHidden = directorys.count > 0 || fileList.count > 0
    }
    
    private func setSearchBarPlaceHolder() {
        if let placeHolder = fileBrowser?.searchBarPlaceHolder {
            self.searchBar.placeholder = placeHolder
        }
    }
}
