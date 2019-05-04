//
//  HttpMgr.swift
//  MovieTest
//
//  Created by Rydus on 18/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit
import Alamofire
import APESuperHUD

//  MARK: Http Manager
final class HttpMgr {
    
    static var shared = HttpMgr()
    
    //  MARK:   Upload Data To The Web Server
    func get(uri:String, completion: @escaping (_ result: NSDictionary)->()) {
        
        let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
        serialQueue.sync {
            
            DispatchQueue.main.async() {
                //  Add Hud
                APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "Please wait...")
            }
            
            //  Requesting to server...
            Common.Log(str: uri)
            Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    
                    //  Getting Response from server
                    Common.Log(str:response.description)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        APESuperHUD.dismissAll(animated: true)
                    })
                    
                    //  Checking server response...
                    if let jsonDict = response.result.value as? NSDictionary {
                        //  call back response
                        completion(jsonDict);
                    }
                    else {
                        DispatchQueue.main.async() {
                            let alertController = UIAlertController(title: "Alert", message: "Internet Issue", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(OKAction)
                        }
                    }
                }
        }
    }
    
    //  MARK:   Exclude function from test. sample for uploading multipart data to the server
    func postMultipart(uri:String, params: Dictionary<String, Any>,completion: @escaping (_ result: NSDictionary)->()) {
        
        APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "Loading...")
        Alamofire.upload(
            multipartFormData: { multipartFormData in
           
                //  Static data for WS
            multipartFormData.append( (UIDevice.current.identifierForVendor?.uuidString.data(using: .utf8)!)!, withName:"udid")
                multipartFormData.append("test.munir".data(using: String.Encoding.utf8)!, withName:"device_token")
                //multipartFormData.append(WS_KEY.data(using: String.Encoding.utf8)!, withName:"ws_key")
                
                //  Dynamic data for WS
                for (key, value) in params {
                    if key.hasPrefix("image") {
                        if let imageData = (value as! UIImage).pngData() {
                            multipartFormData.append(imageData, withName: "file", fileName: "image.png", mimeType: "image/png")
                        }
                        else if let imageData = (value as! UIImage).jpegData(compressionQuality: 0.5) {
                            multipartFormData.append(imageData, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
                        }
                    }
                    else {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
        },
            to: uri,
            encodingCompletion: { encodingResult in
                debugPrint(uri)
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            APESuperHUD.dismissAll(animated: true)
                        })
                        
                        if let jsonDict = response.result.value as? NSDictionary {
                            
                            let error_type = jsonDict.value(forKey: "ERROR_CODE") as? Int
                            if(error_type==1) {
                                completion(jsonDict)
                            }
                            else {
                                let alertController = UIAlertController(title: "Alert", message: jsonDict.object(forKey: "REASON") as? String, preferredStyle: .alert)
                                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(OKAction)
                            }
                        }
                        else {
                            let alertController = UIAlertController(title: "Alert", message: "Internet Issue", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(OKAction)
                        }
                        }
                        .uploadProgress { progress in // main queue by default
                            //self.img1Progress.alpha = 1.0
                            //self.img1Progress.progress = Float(progress.fractionCompleted)
                            print("Upload Progress: \(progress.fractionCompleted)")
                    }
                    return
                case .failure(let encodingError):
                    debugPrint(encodingError)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        APESuperHUD.dismissAll(animated: true)
                    })
                    let alertController = UIAlertController(title: "Alert", message: "Internet Issue", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(OKAction)
                    //progressBar.stopAnimating()
                    //progressBar.removeFromSuperview()
                    break;
                }
        })
    }
    
    //  MARK:   Download Image/Binary From Web Server
    func getImage(uri: String, completion: @escaping (Data) -> ()) {
        
        let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
        serialQueue.sync {
            /*Alamofire.request(uri).responseData { (response) in
                if response.error != nil {
                    print(response.result)
                    // Show the downloaded image:
                    if let data = response.data {
                        completion(data)
                    }
                }
            }*/
            
            let picUrl = URL(string: uri)!
            
            // Creating a session object with the default configuration.
            // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
            let session = URLSession(configuration: .default)
            
            // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
            let downloadPicTask = session.dataTask(with: picUrl) { (data, response, error) in
                // The download has finished.
                if let e = error {
                    Common.Log(str: "Error downloading picUrl: \(e)")
                } else {
                    // No errors found.
                    // It would be weird if we didn't have a response, so check for that too.
                    if let res = response as? HTTPURLResponse {
                        Common.Log(str: "Downloaded picUrl with response code \(res.statusCode)")
                        if let imageData = data {
                            // Finally convert that Data into an image and do what you wish with it.
                            //let image = UIImage(data: imageData)
                            // Do something with your image.
                            completion(imageData)
                        } else {
                            Common.Log(str: "Couldn't get image: Image is nil")
                        }
                    } else {
                        Common.Log(str: "Couldn't get response code for some reason")
                    }
                }
            }
            
            downloadPicTask.resume()
        }
    }
}
