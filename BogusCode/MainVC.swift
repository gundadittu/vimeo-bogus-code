//
//  MainVCViewController.swift
//  BogusCode
//
//  Created by Aditya Gunda on 1/21/18.
//  Copyright © 2018 Vimeo. All rights reserved.
//

import UIKit
import SafariServices

class MainVC: UIViewController {
    
    var objects = [Video]()
    var url: String = "https://api.vimeo.com/channels/staffpicks/videos"
    var baseURL: String = "https://api.vimeo.com"
    var nextURL: String?
    var kOneConstant = 1
    
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let spinner2 = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Vimeo Staff Picks"
        
        let nib = UINib(nibName: "VideoCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "VideoCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        self.tableView.backgroundView = self.spinner
        
        self.getStaffList(completion: handleResult)
    }

    func getStaffList(url: String = "https://api.vimeo.com/channels/staffpicks/videos", completion: @escaping ((Result<[Video]>) -> Void)) {
        dataTask?.cancel()
        
        let requestURL = NSURL(string: url)! as URL
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.cachePolicy = .returnCacheDataElseLoad
        request.setValue("Bearer 2c45fbe08f46fb2cbfe0f5143e8bbdfc", forHTTPHeaderField: "Authorization")
        
        self.dataTask = self.defaultSession.dataTask(with: request) { (data, response, error) in
            if let unwrappedError = error {
                completion(.failure(unwrappedError as NSError))
                return
            } else if let unwrappedData = data, let unwrappedResponse = response {
                
                let statusCode = (unwrappedResponse as! HTTPURLResponse).statusCode
                switch(statusCode) {
                case 200...299:
                    break
                case 304:
                    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
                    completion(.failure(error))
                    return
                case 400:
                    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
                    completion(.failure(error))
                    return
                case 404:
                    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: nil)
                    completion(.failure(error))
                    return
                default:
                    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) else { return }
                let dict = json as! [String: Any]
               // print(dict)
                if let paging = dict["paging"] as? [String: Any], let next = paging["next"] as? String {
                    //print(next)
                    self.nextURL = self.baseURL + next
                    //print(self.nextURL)
                } else {
                    self.nextURL = nil
                }
                let data = dict["data"] as! [[String: Any]]
                var videosArr = [Video]()
                for obj in data {
                    if let video = Video(json: obj) {
                       videosArr.append(video)
                    } else {
                        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotParseResponse, userInfo: nil)
                        completion(.failure(error))
                        return
                    }
                }
                completion(.success(videosArr))
            }
        }
        self.dataTask?.resume()
    }
    
    func handleResult(_ result: Result<[Video]>) {
        DispatchQueue.main.async {
            self.tableView.separatorStyle = .singleLine
            self.spinner.stopAnimating()
            self.spinner2.stopAnimating()
        }
        
        switch result{
        case .success(let array):
            self.objects += array
            break
        case .failure(let error):
            var message: String = ""
            
            switch error.code {
            case NSURLErrorNetworkConnectionLost:
                message = "It looks like you're not connected to the internet."
                break
            case NSURLErrorHTTPTooManyRedirects:
                message = "It looks like you've triggered too many requests."
                break
            case NSURLErrorCancelled:
                message = "It looks like your request was canceled."
                break
            case NSURLErrorCannotConnectToHost:
                message =  "It looks like we couldn't connect with Vimeo's servers."
                break
            case NSURLErrorBadURL:
                message = "There was something wrong with our request's configurations."
                break
            case NSURLErrorCannotParseResponse:
                message = "It looks like there was an issue displaying the videos."
                break
            case NSURLErrorResourceUnavailable:
                message = "It looks like the Staff Picks channel is unavailable right now."
                break
            default:
                break
            }
            let alertController = UIAlertController(title: "Something went wrong!", message:
                message, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            break
        }
      
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        return
    }

}

extension MainVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = self.tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        if let title = objects[indexPath.row].title {
            cell.titleLabel.text = title 
        }
        if let author = objects[indexPath.row].author {
            cell.authorName.text = author 
        }
        if let playCount = objects[indexPath.row].playCount {
            cell.playCountLabel.text = "\(playCount) plays"
        } else {
             cell.playCountLabel.text = ""
        }
        if let likesCount = objects[indexPath.row].likesCount {
            cell.likesCountLabel.text = "\(likesCount) likes"
        } else {
            cell.likesCountLabel.text = ""
        }
        if let commentsCount = objects[indexPath.row].commentsCount {
            cell.commentsCountLabel.text = "\(commentsCount) comments"
        } else {
            cell.commentsCountLabel.text = ""
        }
        if let releaseDateString = objects[indexPath.row].releaseDateString {
            cell.releaseDateLabel.text = releaseDateString + " ago"
        } else {
            cell.releaseDateLabel.text = ""
        }
        
        if let imageData = objects[indexPath.row].imageData {
            cell.thumbnail.image = UIImage(data: imageData)
            cell.thumbnail.layer.cornerRadius = 5.0
            cell.thumbnail?.clipsToBounds = true
            cell.thumbnail.contentMode = .scaleAspectFit
        }
        if let imageData = objects[indexPath.row].authorProfileImageData {
            cell.profileImage.image = UIImage(data: imageData)
            cell.profileImage?.clipsToBounds = true
            cell.profileImage.layer.cornerRadius = 10
            cell.profileImage.contentMode = .scaleAspectFit
        }
        
        if let duration = objects[indexPath.row].duration {
            var durationString = ""
            let hours = Int(duration / 3600)
            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
            
            if hours >= 10 {
                durationString += "\(hours):"
            } else if hours >= 1 {
                durationString += "0\(hours):"
            } else {
                 durationString += "00:"
            }
            if minutes >= 10 {
                durationString += "\(minutes):"
            } else if minutes >= 1 {
                durationString += "0\(minutes):"
            } else {
                durationString += "00:"
            }
            if seconds >= 10 {
                durationString += "\(seconds)"
            } else if seconds >= 1 {
                durationString += "0\(seconds)"
            } else {
                durationString += "00"
            }
            
            let durationLabel = UILabel()
            durationLabel.text = durationString
            durationLabel.backgroundColor = UIColor.black
            durationLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            durationLabel.textAlignment = NSTextAlignment.left
            durationLabel.numberOfLines = 1
            durationLabel.textColor = UIColor.white
            durationLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.thumbnail.addSubview(durationLabel)
            durationLabel.bottomAnchor.constraint(equalTo:  cell.thumbnail.bottomAnchor).isActive = true
            durationLabel.leftAnchor.constraint(equalTo:  cell.thumbnail.leftAnchor, constant: 0).isActive = true
            durationLabel.rightAnchor.constraint(equalTo:  cell.thumbnail.rightAnchor, constant: 0).isActive = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let string = self.objects[indexPath.row].videoURLString {
            let svc = SFSafariViewController(url: URL(string: string)!)
            self.present(svc, animated: true){ return }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.objects.count {
            if let nextURL = self.nextURL {
                self.nextURL = nil
                self.spinner2.startAnimating()
                self.spinner2.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                self.tableView.tableFooterView?.isHidden = false
                self.tableView.tableFooterView = self.spinner2
                
                self.getStaffList(url: nextURL, completion: handleResult)
            }
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
