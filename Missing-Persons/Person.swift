//
//  Person.swift
//  Missing-Persons
//
//  Created by Minni K Ang on 2016-07-10.
//  Copyright © 2016 CreativeIce. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class Person: NSObject, NSCoding {
    
    var faceId: String?
    var personImage: UIImage?
    var personImageUrl: String?
    
    init(personImageUrl: String) {
        self.personImageUrl = personImageUrl
    }
    
    override init() {
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.personImageUrl = aDecoder.decodeObjectForKey("personImageUrl") as? String
        self.personImage = aDecoder.decodeObjectForKey("personImage") as? UIImage
        self.faceId = aDecoder.decodeObjectForKey("faceId") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.personImageUrl, forKey: "personImageUrl")
        aCoder.encodeObject(self.personImage, forKey: "personImage")
        aCoder.encodeObject(self.faceId, forKey: "faceId")
    }
    
    func downloadFaceId() {
        
        if let img = personImage, let imgData = UIImageJPEGRepresentation(img, 0.8) {
            
            FaceService.instance.client.detectWithData(imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces: [MPOFace]!, err: NSError!) in
            
                if err == nil {
                    var faceId: String?
                    for face in faces {
                        faceId = face.faceId
                        print("New FaceId: \(faceId)")
                        NSUserDefaults.standardUserDefaults().setValue(faceId, forKey: "faceId")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        break
                    }
                    
                    self.faceId = faceId
                    }
            
                })
            }
        }
}
