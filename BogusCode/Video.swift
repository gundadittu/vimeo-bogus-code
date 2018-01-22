//
//  Video.swift
//  BogusCode
//
//  Created by Aditya Gunda on 1/20/18.
//  Copyright © 2018 Vimeo. All rights reserved.
//

import Foundation

struct Video : Codable {
    var title: String?
    var author: String?
    var playCount: Int?
    var duration: Double?
    var authorProfileImageURLString: String?
    var authorProfileImageData: Data?
    var imageURLString: String?
    var imageData: Data?
    var releaseDate: Date?
    var releaseDateString: String?
    var description: String?
    var commentsCount: Int?
    var likesCount: Int?
    var videoURLString: String?
    

    init?(json obj: [String: Any]) {
        let dg = DispatchGroup()
    
        
        if let name = obj["name"] as? String{
            self.title = name 
        }
        
        if let duration = obj["duration"] as? Double {
            self.duration = duration
        }
        
        if let releaseTime = obj["release_time"] {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let releaseDate = dateFormatter.date(from: releaseTime as! String)
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.includesApproximationPhrase = true
            formatter.includesTimeRemainingPhrase = false
            formatter.maximumUnitCount = 1
            formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
            let dateRelativeString = formatter.string(from: releaseDate!, to: Date())
            
            self.releaseDate = releaseDate
            self.releaseDateString = dateRelativeString
        }
        
        if let pictures = obj["pictures"] as? [String: Any], let sizes = pictures["sizes"] as? [[String:Any]] {
            let firstImage = sizes[0]
            let firstImageURLString = firstImage["link"] as! String
            
            self.imageURLString = firstImageURLString
        }
        
        if let user = obj["user"] as? [String: Any], let authorName = user["name"] as? String, let userPictures = user["pictures"] as? [String: Any] {
            self.author = authorName
            let userPictureSizes = userPictures["sizes"] as! [[String: Any]]
             let firstUserPicture = userPictureSizes[0]
            if let firstUserPictureURLString = firstUserPicture["link"] as? String {
                self.authorProfileImageURLString = firstUserPictureURLString
            }
        }
        
        if let link = obj["link"] as? String {
            self.videoURLString = link
        }
        
        if let stats = obj["stats"] as? [String:Any], let playCount = stats["plays"] as? Int {
            self.playCount = playCount
        }
        
        if let metaData = obj["metadata"] as? [String: Any], let connections = metaData["connections"] as? [String: Any] {
            if let likes = connections["likes"] as? [String: Any], let likesCount = likes["total"] as? Int {
                 self.likesCount = likesCount
            }
            if let comments = connections["comments"] as? [String: Any], let commentsCount = comments["total"] as? Int {
                self.commentsCount = commentsCount
            }
        }
   
        if let description = obj["description"] as? String  {
            self.description = description
        }
        
        guard let authorImageURL = self.authorProfileImageURLString , let thumbnailImageURL = self.imageURLString else { return }

        let imageCache = NSCache<NSString, AnyObject>()
        if let cachedImage = imageCache.object(forKey: thumbnailImageURL as NSString) as? Data, let cachedAuthorImage = imageCache.object(forKey: authorImageURL as NSString) as? Data{
            self.imageData = cachedImage
            self.authorProfileImageData = cachedAuthorImage
        } else {
            var dataTask: URLSessionDataTask?
            let defaultSession = URLSession(configuration: .default)
            
            let firstImageURL = NSURL(string: thumbnailImageURL)! as URL
            var request = URLRequest(url: firstImageURL)
            request.httpMethod = "GET"
            request.setValue("Bearer 2c45fbe08f46fb2cbfe0f5143e8bbdfc", forHTTPHeaderField: "Authorization")
            
            dg.enter()
            dataTask = defaultSession.dataTask(with: request)  { (imageData, response, error) in
                if error != nil {
                    print ("error")
                } else {
                    if let unwrappedImageData = imageData{
                        imageCache.setObject(unwrappedImageData as AnyObject, forKey: thumbnailImageURL as NSString)
                    }
                }
                dg.leave()
            }
            dataTask?.resume()

            dg.wait()
            
            let firstUserImageURL = NSURL(string: authorImageURL)! as URL
            var request2 = URLRequest(url: firstUserImageURL)
            request2.httpMethod = "GET"
            request2.setValue("Bearer 2c45fbe08f46fb2cbfe0f5143e8bbdfc", forHTTPHeaderField: "Authorization")
            
            dg.enter()
            dataTask = defaultSession.dataTask(with: request2)  { (imageData, response, error) in
                if error != nil {
                    print ("error")
                } else {
                    if let unwrappedImageData = imageData{
                        imageCache.setObject(unwrappedImageData as AnyObject, forKey: authorImageURL as NSString)
                    }
                }
                dg.leave()
            }
            dataTask?.resume()
            
            dg.wait()
            let cachedImage = imageCache.object(forKey: thumbnailImageURL as NSString) as! Data
            let cachedAuthorImage = imageCache.object(forKey: authorImageURL as NSString) as! Data
            self.imageData = cachedImage
            self.authorProfileImageData = cachedAuthorImage
        }
    }
}
