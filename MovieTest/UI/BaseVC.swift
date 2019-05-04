//
//  BaseVC.swift
//  MovieTest
//
//  Created by Rydus on 18/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit
import ReachabilitySwift

class BaseVC: UIViewController {
    
    var isNetAvailable = true
    let reachability = Reachability()!
    
    deinit {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        Common.Log(str:reachability.currentReachabilityString)
        switch reachability.currentReachabilityString.lowercased() {
        case "wifi":
            Common.Log(str:"Reachable via WiFi")
            isNetAvailable = true
            break
        case "cellular":
            Common.Log(str:"Reachable via Cellular")
            isNetAvailable = true
            break
        default:
            Common.Log(str:"Network not reachable")
            DispatchQueue.main.async {
                self.showAlert(msg:"Sorry, internet is not available")
            }
            isNetAvailable = false
            break
        }
    }
    
    //  MARK:   Custom Methods
    @objc func setMainMovie2DB(json:NSDictionary) {
        let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
        serialQueue.sync {
            if DBMgr.shared.getNumRows(entity: "MainMovie") > 0 {
                DBMgr.shared.delRows(entity: "MainMovie")
            }
            let mainMovie:MainMovie  = MainMovie(context: DBMgr.shared.context)
            mainMovie.json = json as NSObject
            DBMgr.shared.save()
        }
    }

    func getMainMovieFromDB(completion: @escaping (_ result: NSDictionary)->()) {
        let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
        serialQueue.sync {
            if DBMgr.shared.getNumRows(entity: "MainMovie") > 0 {
                DBMgr.shared.getMainMovie(completion: { (obj) in
                    let mainMovie:MainMovie = obj
                    completion(mainMovie.json as! NSDictionary)
                })
            }
        }
    }
    
    func showAlert(msg:String) {
        let alert = UIAlertController(title:nil, message:msg, preferredStyle:.alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        self.navigationController?.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            alert.dismiss(animated:true)
        }
    }
    
    func isLandscape()->Bool {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        // it is important to do this after presentModalViewController:animated:
        if (statusBarOrientation != UIInterfaceOrientation.portrait
            && statusBarOrientation != UIInterfaceOrientation.portraitUpsideDown){
            return true
        }
        else {
            return false
        }
    }
}

extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }    
}
