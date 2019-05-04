//
//  DetailMovieVC.swift
//  MovieTest
//
//  Created by Rydus on 18/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import XCDYouTubeKit

class DetailMovieVC: BaseVC {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var jsonArray : NSArray = NSArray()
    
    var movie_id:Int = 0
    
    var barHeight:CGFloat = 0
    
    var width = CGFloat()
    var height = CGFloat()
    
    var linePA:CGFloat = 5

    //  ui controls
    let backdrop_pathImage = UIImageView()
    let trailerView = UIView()
    let nameLabel  = UILabel()
    let watchBtn  = MyButton(type: UIButton.ButtonType.custom)
    let genresTitleLabel  = UILabel()
    let genresLabel  = UILabel()
    let dtTitleLabel  = UILabel()
    let dtLabel  = UILabel()
    let overviewTitleLabel  = UILabel()
    let overviewLabel  = UILabel()
    var overviewTxt = String()
    
    //  XCDYoutube
    let playerViewController = AVPlayerViewController()
    
    //  VC Lifecycle
    deinit {

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // Do any additional setup after loading the view.
        self.title = "Movie Detail"
        WSRequest();
     }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {        
        
        width = size.width
        height = size.height
        
         if !UIDevice.current.orientation.isPortrait {
            Common.Log(str: "Landscape")
            linePA = 7
            self.setLandscapePosition()
        } else {
            Common.Log(str: "Portrait")
            linePA = 5
            self.setPortraitPosition()
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }

    //  MARK:   XCDYouTubePlayer Observer for 'done' and on 'finished' capture
    
    struct YouTubeVideoQuality {
        static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
        static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
        static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        
        self.playerViewController.removeObserver(self, forKeyPath: #keyPath(UIViewController.view.frame))
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        if (self.playerViewController.isBeingDismissed) {
            // Video was dismissed -> apply logic here
            Common.Log(str: "XCDYoutube Player Done Clicked")
        }
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        Common.Log(str: "XCDYoutube Player Streaming Complted")
        self.playerViewController.dismiss(animated: true);
    }
    
    //
    
    
    //  MARK:   Custom Render Methods
    //  writing code is more accurate to render ui control into specific position and easy through constraint + vary for trait for changing postion in orientation
    func renderMovieDetail(dic:NSDictionary) {
        
        for sview in scrollView.subviews {
            sview.removeFromSuperview()
        }
        
        if let backdrop_path = dic.object(forKey: "backdrop_path") as? String {
            
            //backdrop_pathImage.contentMode = .scaleAspectFill
            HttpMgr.shared.getImage(uri: String(format:"%@%@",Server.API_POSTER_IMAGE_URL, backdrop_path)) { (data) in
                DispatchQueue.main.async {
                    self.backdrop_pathImage.image = UIImage(data: data)
                }
            };
            
            scrollView.addSubview(backdrop_pathImage)
        }
        
        if let belongs_to_collection = dic.object(forKey: "belongs_to_collection") as? NSDictionary {
            
            let name = belongs_to_collection.value(forKey: "name") as! String
            
            nameLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 27)
            nameLabel.text = name
            nameLabel.textAlignment = .left
            trailerView.addSubview(nameLabel)
            
            //
            
            watchBtn.backgroundColor = .groupTableViewBackground
            if let imdb_id = dic.value(forKey: "imdb_id") as? String {
                watchBtn.id = imdb_id
            }
            watchBtn.addTarget(self, action: #selector(watchTrailerClicked(sender:)), for: .touchUpInside)
            watchBtn.setTitle("Watch Trailer", for: .normal)
            watchBtn.setTitleColor(.black, for: .normal)
            watchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            //watchBtn.titleLabel?.font = UIFont(name: "Viga-Regular", size: 30)!
            trailerView.addSubview(watchBtn)
            
            scrollView.addSubview(trailerView)
        }
        
        if let genres = dic.object(forKey: "genres") as? NSArray {
            
            var genStr = ""
            //let genresStr = genres.obj(forKey: "").componentsJoined(by: ", ")
            for gen in genres as NSArray {
                genStr += (gen as AnyObject).value(forKey: "name") as! String
                genStr += ", "
            }
            genStr = String(genStr.dropLast(2))
            Common.Log(str: genStr)
            
            genresTitleLabel.font = UIFont(name: "Viga-Regular", size: 25)
            genresTitleLabel.text = "Genres"
            genresTitleLabel.textAlignment = .left
            scrollView.addSubview(genresTitleLabel)
            
            //
            
            genresLabel.font = UIFont.systemFont(ofSize: 25)
            genresLabel.text = genStr
            genresLabel.textAlignment = .left
            scrollView.addSubview(genresLabel)
        }
        
        if let release_date = dic.object(forKey: "release_date") as? String {
            
            dtTitleLabel.font = UIFont(name: "Viga-Regular", size: 25)
            dtTitleLabel.text = "Date"
            dtTitleLabel.textAlignment = .left
            scrollView.addSubview(dtTitleLabel)
            
            //
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            let showDate = inputFormatter.date(from: release_date)
            inputFormatter.dateFormat = "dd.MM.yyyy"
            let dtString = inputFormatter.string(from: showDate!)
            
            dtLabel.font = UIFont.systemFont(ofSize: 25)
            dtLabel.text = dtString
            dtLabel.textAlignment = .left
            scrollView.addSubview(dtLabel)
        }
        
        if let overview = dic.object(forKey: "overview") as? String {

            overviewTxt = overview
            
            overviewTitleLabel.font = UIFont(name: "Viga-Regular", size: 25)
            overviewTitleLabel.text = "Overview"
            overviewTitleLabel.textAlignment = .left
            scrollView.addSubview(overviewTitleLabel)
            
            //
            
            overviewLabel.font = UIFont.systemFont(ofSize: 25)
            overviewLabel.text = overview
            overviewLabel.textAlignment = .left
            overviewLabel.lineBreakMode = .byWordWrapping
            overviewLabel.numberOfLines = 20
            scrollView.addSubview(overviewLabel)
        }
    }
    
    @objc func watchTrailerClicked(sender:MyButton) {
        
        var url = Server.API_WATCH_TRAILER_URL
        url = url.replacingOccurrences(of: "#IMDB_ID#", with: sender.id!) //  sender.id = imdb_id
        HttpMgr.shared.get(uri: url) { (dic) in
            if dic.count > 0 {
               if let youtubeIDArr = dic.object(forKey: "results") as? Array<Any> {
                    if youtubeIDArr.count > 0 {
                        if let dicYoutube = youtubeIDArr[0] as? NSDictionary {
                            if let videoIdentifier = dicYoutube.value(forKey: "key") as? String {
                                
                                //  Ready to Play Youtube Video                                
                                DispatchQueue.main.async {
                                    
                                    self.present(self.playerViewController, animated: true, completion: nil)
                                    
                                    XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { (video: XCDYouTubeVideo?, error: Error?) in
                                        if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                                            self.playerViewController.player = AVPlayer(url: streamURL)
                                            self.playerViewController.player?.play()
                                            
                                            //  Observer for Done click
                                            self.playerViewController.addObserver(self, forKeyPath:#keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
                                            
                                            //  Observer for movie finish
                                            NotificationCenter.default.addObserver(self,
                                                                                   selector: #selector(self.playerItemDidReachEnd),
                                                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                                                   object: nil)
                                            
                                        } else {
                                            self.showAlert(msg: error?.localizedDescription ?? "")
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.showAlert(msg: "Sorry, Youtube-VideoIdentifer ID as key not found")
                                }
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.showAlert(msg: "Sorry, IMDB_ID result items not found")
                        }
                    }
               }
               else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: "Sorry, IMDB_ID result not found")
                    }
               }
            }
            else {
                DispatchQueue.main.async {
                    self.showAlert(msg: "Sorry, IMDB_ID not found")
                }
            }
        };
    }
    
    //  MARK:   WS
    func WSRequest() {
        var url = Server.API_MOVIE_DB_DETAIL_URL
        url = url.replacingOccurrences(of: "#MOVIE_ID#", with: String(format:"%i", movie_id))
        HttpMgr.shared.get(uri: url) { (dic) in
            
            if dic.count > 0 {
                
                /*if !UIDevice.current.orientation.isPortrait {
                    self.linePA = 7
                    self.setLandscapePosition()
                }
                else {
                    self.linePA = 5
                    self.setPortraitPosition()
                }*/
                
                DispatchQueue.main.async {
                    
                    //  render ui controls as per screen orientation
                    self.renderMovieDetail(dic: dic)
                    
                    if self.isLandscape() {
                        self.linePA = 7
                        //  set ui controls position as landscape mode
                        self.setLandscapePosition()
                    } else {
                        self.linePA = 5
                        //  set ui controls position as portrait mode
                        self.setPortraitPosition()
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showAlert(msg: "Sorry, movie detail result not found")
                }
            }
        };
    }
    
    func setPortraitPosition() {
        
        let w:CGFloat = width*90/100
        var y:CGFloat = 0
        var h:CGFloat = height*30/100
        
        Common.Log(str: String(format:"portrait width---%.01f",width))
        Common.Log(str: String(format:"portrait height---%.01f",height))
        
        //  status and navigation bar height
        barHeight = (self.navigationController!.navigationBar.frame.size.height) + UIApplication.shared.statusBarFrame.height
        
        //  scrollview frame
        scrollView.frame = CGRect(x: 0, y: barHeight+2, width: width, height: height-(barHeight+2))
        
        //  cover image
        backdrop_pathImage.frame = CGRect(x:0, y:y, width:width, height:h);
        
        //  name and watch trailer view
        y = y+h+1
        h = height*16/100
        trailerView.frame = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        //{
            //  name label
            nameLabel.frame = CGRect(x:0, y:20, width:trailerView.frame.size.width, height:(trailerView.frame.size.height/2)-20);
            nameLabel.sizeToFit()
        
            //  watch trailer button
            watchBtn.frame = CGRect(x:0, y:trailerView.frame.size.height/2, width:trailerView.frame.size.width, height:trailerView.frame.size.height/2);
        //}
        
        commonPosition(w: w, hh: h, yy: y)
    }
    
    func setLandscapePosition() {
        
        let w = width*90/100
        let y:CGFloat = 0
        let h:CGFloat = height*60/100
        
        Common.Log(str: String(format:"landscape width---%.01f",width))
        Common.Log(str: String(format:"landscape height---%.01f",height))
        
        //  status and navigation bar height
        barHeight = (self.navigationController!.navigationBar.frame.size.height) + UIApplication.shared.statusBarFrame.height
        
        //  scrollview frame
        scrollView.frame = CGRect(x: 0, y: barHeight+7, width: width, height: height-(barHeight+7))
        
        //  cover image
        //{ 2 columns div
            backdrop_pathImage.frame = CGRect(x:0, y:y, width:width*50/100, height:h);
        
            //  name and watch trailer view
            trailerView.frame = CGRect(x:width*52/100, y:y, width:width*48/100, height:h);
            //{
                //  name label
                nameLabel.frame = CGRect(x:0, y:trailerView.frame.size.height*7/100, width:trailerView.frame.size.width, height:trailerView.frame.size.height*65/100);
                    nameLabel.sizeToFit()
        
                //  watch trailer button
                watchBtn.frame = CGRect(x:0, y:trailerView.frame.size.height*76/100, width:trailerView.frame.size.width, height:trailerView.frame.size.height*23/100);
            //}
        //}
        
        commonPosition(w: w, hh: h, yy: y)
    }
    
    func commonPosition(w:CGFloat, hh:CGFloat, yy:CGFloat) {
        
        var y:CGFloat = yy
        var h:CGFloat = hh
        
        //  genres title
        y = y+h+20
        h = height*linePA/100
        genresTitleLabel.frame  = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  genres
        y = y+h+1
        h = height*linePA/100
        genresLabel.frame  = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  date title
        y = y+h+20
        h = height*linePA/100
        dtTitleLabel.frame  = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  date
        y = y+h+1
        h = height*linePA/100
        dtLabel.frame = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  overview title
        y = y+h+20
        h = height*linePA/100
        overviewTitleLabel.frame = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  overview
        y = y+h+1
        h = overviewLabel.estimatedHeight(forWidth: w, text: overviewTxt, ofSize: 25)
        
        overviewLabel.frame = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        overviewLabel.textAlignment = .left
        overviewLabel.sizeToFit()
        
        //  scrollview content size
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrollView.contentSize = CGSize(width: width, height: y+h)
    }
}

extension UILabel {
    //  MARK:   Get UILabel height as per text length and font size
    func estimatedHeight(forWidth: CGFloat, text: String, ofSize: CGFloat) -> CGFloat {
        let size = CGSize(width: forWidth, height: CGFloat(MAXFLOAT))
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: ofSize)]
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        return ceil(rectangleHeight)
    }
}
