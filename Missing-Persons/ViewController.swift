//
//  ViewController.swift
//  Missing-Persons
//
//  Created by Minni K Ang on 2016-07-10.
//  Copyright © 2016 CreativeIce. All rights reserved.
//

import UIKit
import ProjectOxfordFace


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    
    var selectedPerson: Person?
    var hasSelectedImage = false
    
    let missingPeople = [
    Person(personImageUrl: "person1.jpg"),
    Person(personImageUrl: "person2.jpg"),
    Person(personImageUrl: "person3.jpg"),
    Person(personImageUrl: "person4.jpg"),
    Person(personImageUrl: "person5.jpg"),
    Person(personImageUrl: "person6.png")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePicker.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(loadPicker(_:)))
        tap.numberOfTapsRequired = 1
        selectedImg.addGestureRecognizer(tap)
        
        let missingPeopleData = NSKeyedArchiver.archivedDataWithRootObject(missingPeople)
        NSUserDefaults.standardUserDefaults().setObject(missingPeopleData, forKey: "missingPeople")
        NSUserDefaults.standardUserDefaults().synchronize()

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return missingPeople.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PersonCell", forIndexPath: indexPath) as! PersonCell
        let person = missingPeople[indexPath.row]
        cell.configureCell(person)
        return cell
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImg.image = pickedImage
            hasSelectedImage = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadPicker(gesture: UITapGestureRecognizer) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedPerson = missingPeople[indexPath.row]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PersonCell
        cell.configureCell(selectedPerson!)
        cell.setSelected()
    }
    
   
    @IBAction func checkForMatch(sender: AnyObject) {
        if selectedPerson == nil || !hasSelectedImage {
            showErrorAlert()

        } else {
            
            if let myImg = selectedImg.image, let imgData = UIImageJPEGRepresentation(myImg, 0.8) {
 
                FaceService.instance.client.detectWithData(imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces: [MPOFace]!, err: NSError!) in
                    
                    if err == nil {
                        var faceId: String?
                        for face in faces {
                            faceId = face.faceId
                            print("Selected FaceId \(faceId)")
                            break
                        }
                        
                        if faceId != nil {
                            FaceService.instance.client.verifyWithFirstFaceId(self.selectedPerson!.faceId, faceId2: faceId, completionBlock: { (result: MPOVerifyResult!, err: NSError!) in
                            
                                if err == nil {
                                    let confidenceLevel = result.confidence
                                    print(result.confidence)
                                    print(result.isIdentical)
                                    
                                    if result.isIdentical == true {
                                        self.showMatch(confidenceLevel)
                                    } else {
                                       self.showNoMatch(confidenceLevel)
                                    }
                                } else {
                                    print(err.debugDescription)
                                }
                            })
                        }
                    }
                })
            }
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Select Person", message: "Please select a missing person to check", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showMatch(confidenceLevel: NSNumber) {
        let alert = UIAlertController(title: "Match Found", message: "Match ratio is \(confidenceLevel)", preferredStyle:  UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func showNoMatch(confidenceLevel: NSNumber) {
        let alert = UIAlertController(title: "No Match", message: "Match ratio is \(confidenceLevel)", preferredStyle:  UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
}

