//
//  FaceService.swift
//  Missing-Persons
//
//  Created by Minni K Ang on 2016-07-10.
//  Copyright © 2016 CreativeIce. All rights reserved.
//

import Foundation
import ProjectOxfordFace

class FaceService {
    static let instance = FaceService()
    
    let client = MPOFaceServiceClient(subscriptionKey: "774afab2c8d0479ab43248184ea1d5c2")
}