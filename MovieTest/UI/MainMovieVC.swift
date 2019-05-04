//
//  MainMovieVC.swift
//  MovieTest
//
//  Created by Rydus on 18/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import XCDYouTubeKit

class MainMovieVC: BaseVC,  UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: MySearchBar!
    
    let cellReuseIdentifier = "cell"
    
    var jsonArray : NSArray = NSArray()
    
    var isLandscape:Bool = false
    
    var width = CGFloat()
    var height = CGFloat()
    
    //  VC Lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        width = UI.getScreenSize().width
        height = UI.getScreenSize().height        

        if(isNetAvailable) { //  normal
            WSRequest();
        }
        else {
            getMainMovieFromDB { (dic) in
                if let arr = dic.object(forKey: "results") {
                    DispatchQueue.main.async {
                        self.jsonArray = arr as! NSArray
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        width = size.width
        height = size.height
        
        if !UIDevice.current.orientation.isPortrait {
            Common.Log(str: "Landscape")
            isLandscape = true
        } else {
            Common.Log(str: "Portrait")
            isLandscape = false
        }
    }
    
    //  MARK:   Keyboard Notifications Selectors
    @objc func keyboardWillAppear(_ notification: Notification) {
        //Do something here
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            searchBar.frame = CGRect(x: 0, y: UI.getScreenSize().height - (keyboardHeight + searchBar.frame.size.height), width: width, height: searchBar.frame.size.height)
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        //Do something here
        searchBar.frame = CGRect(x: 0, y: UI.getScreenSize().height - searchBar.frame.size.height, width: width, height: searchBar.frame.size.height)
    }
    
    //  MARK:   WS    
    func WSRequest() {        
        HttpMgr.shared.get(uri: Server.API_MOVIE_DB_URL) { (dic) in
            if let arr = dic.object(forKey: "results") {
                
                self.jsonArray = arr as! NSArray
                DispatchQueue.main.async {
                    self.searchBar.isHidden = false
                    self.tableView.reloadData()
                }
                
                //  store json into core data if net is not available then get through there
                self.performSelector(inBackground: #selector(self.setMainMovie2DB(json:)), with: dic)
            }
            else {
                DispatchQueue.main.async {
                    Common.Log(str: "No Result Found")
                    self.searchBar.isHidden = true
                    self.showAlert(msg: "Sorry, movie result not found")
                }
            }
        };
    }
    
    //  MARK:   TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jsonArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MainMovieCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MainMovieCell
        
        let dic = self.jsonArray[indexPath.row] as! NSDictionary
        //Common.Log(str: (arr.value(forKey: "poster_path") as! String));
        
        if let title = dic.value(forKey: "title") as? String {
            cell.title.tag = (dic.value(forKey: "id") as? Int)!
            cell.title.text = title
            cell.title.addTapGestureRecognizer {
                Common.Log(str: String(format:"title tapped at index = %i",cell.title.tag))
                if(self.isNetAvailable) {
                    DispatchQueue.main.async {
                        if let vc = self.storyboard!.instantiateViewController(withIdentifier: "DetailMovieVC") as? DetailMovieVC {
                            vc.movie_id = cell.title.tag
                            vc.width = self.width
                            vc.height = self.height
                            self.navigationController!.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
        
        if let poster_path = dic.value(forKey: "poster_path") as? String {
            HttpMgr.shared.getImage(uri: String(format:"%@%@",Server.API_POSTER_IMAGE_URL, poster_path)) { (data) in
                DispatchQueue.main.async {
                    cell.avator.image = UIImage(data: data)
                }
            };
        }
        
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.5) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Common.Log(str: "You tapped cell number \(indexPath.row).")
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "DetailMovieVC") as! DetailMovieVC
        vc.dicDetails = self.jsonArray[indexPath.row] as! NSDictionary
        self.navigationController!.pushViewController(vc, animated: true)
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let cell:MainMovieCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MainMovieCell
        return cell.frame.size.height
        
        //  Tried to control view height in every devices
        /*var h = CGFloat(getScreenSize().height*20/100)
        switch(UIDevice.current.userInterfaceIdiom) {
            case .phone:
                    if(isLandscape) {
                        h = CGFloat(getScreenSize().height*20/100)
                    }
                    else {
                        h = CGFloat(getScreenSize().height*18/100)
                    }
                    break;
            case .pad:
                    if(isLandscape) {
                        h = CGFloat(getScreenSize().height*25/100)
                    }
                    else {
                        h = CGFloat(getScreenSize().height*22/100)
                    }
                    break;
            case .unspecified:
                break;
            case .tv:
                break;
            case .carPlay:
                break;
        }
        
        return h*/
    }
    
    //  MARK:   Searchbar delegates
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Common.Log(str: searchBar.text!)
        searchBar.resignFirstResponder()
        //  show the predicated result as per search keyword from local json
        getMainMovieFromDB { (dic) in
            if let arr = dic.object(forKey: "results") {
                DispatchQueue.main.async {
                    if (arr as! NSArray).count > 0 {
                        if let keywords = searchBar.text {
                            if keywords.count > 0 {
                                // predicate search result from json now !!
                                let searchArray = MainMovieParser.getTitleMovie(keyword: keywords, arr: arr as! NSArray)
                                if searchArray.count > 0 {
                                    Common.Log(str: searchArray.description)
                                    self.jsonArray = searchArray
                                    self.tableView.reloadData()
                                }
                                else {
                                    self.showAlert(msg: "Sorry, your search record not found")
                                }
                            }
                            else {
                                //  normal
                                self.jsonArray = arr as! NSArray
                                self.tableView.reloadData()
                            }
                        }
                    }
                    else {
                        self.showAlert(msg: "Sorry, no result found")
                    }
                }
            }
        }
    }
}
