//
//  PersonCell.swift
//  Missing-Persons
//
//  Created by Minni K Ang on 2016-07-10.
//  Copyright © 2016 CreativeIce. All rights reserved.
//

import UIKit

class PersonCell: UICollectionViewCell {
    
    @IBOutlet weak var personImage: UIImageView!
    
    var person: Person!
    let baseURL = "http://localHost:6069/img/"
    
    func configureCell(person: Person) {
        self.person = person
        if let url =  NSURL(string: "\(baseURL)\(person.personImageUrl!)") {
        downloadImage(url)
            
            NSUserDefaults.standardUserDefaults().setValue(url, forKey: "personImageUrl")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func downloadImage(url: NSURL) {
        getDataFromUrl(url) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in guard let data = data where error == nil else { return }
                self.personImage.image = UIImage(data: data)
                self.person.personImage = self.personImage.image
                
                if let img = self.personImage.image {
                    NSUserDefaults.standardUserDefaults().setValue(img, forKey: "personImage")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }
        }
    }
    
    func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)) {
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
        }.resume()
    }
    
    func setSelected() {
        personImage.layer.borderWidth = 2.0
        personImage.layer.borderColor = UIColor.blueColor().CGColor
        
        if self.person.faceId != nil {
            self.person.faceId = NSUserDefaults.standardUserDefaults().stringForKey("faceId")
            
        } else {
        self.person.downloadFaceId()
        }
    }

}
