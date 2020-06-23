//
//  EditNotesViewController.swift
//  NoteAppFinalProject IOS
//
//  Created by User on 6/18/20.
//  Copyright © 2020 Simranjeet kaur. All rights reserved.
//

import UIKit
import  CoreData
import MapKit
import AVFoundation

class EditNotesViewController: UIViewController,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate{
    
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var txtView: UITextView!
    
    @IBOutlet weak var captureimg: UIButton!
    
    @IBOutlet weak var recordVideo: UIButton!
    
    @IBOutlet weak var mapbtn: UIButton!
    
    @IBOutlet weak var showImg: UIImageView!
    
    var note:Note!
    var notebook : Notebook?
    var locationManager:CLLocationManager!
    var userIsEditing = true
        var old = true
 var context:NSManagedObjectContext!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = UIColor.black.cgColor
        
        
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
              context = appDelegate.persistentContainer.viewContext
        if (userIsEditing == true) {
            print("Editing an existing note")
           // titleLbl.text = note.title!
           // txtView.text = note.text!
           // self.showImg.image = UIImage(data: note.image! as Data)
           
            mapbtn.isHidden = false
        }
        else {
            print("Going to add a new note to: \(notebook!.name!)")
            txtView.text = ""
            mapbtn.isHidden = true
        }
    }
    
    @IBAction func captureImgAction(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add an Image", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            }
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let imageData = image.pngData() as NSData?

       self.showImg.image = UIImage(data: imageData! as Data)
               self.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           //determineMyCurrentLocation()
       }
    
    
    
    @IBAction func saveBtn(_ sender: UIBarButtonItem) {
       // determineMyCurrentLocation()
                     if (txtView.text!.isEmpty) {
                         print("Please enter some text")
                         return
                     }
                     
                     
                     if (userIsEditing == true) {
                        // note.text = txtView.text!
                     }
                     else {
                         
                         // create a new note in the notebook
                         self.note = Note(context:context)
                         note.setValue(Date(), forKey:"dateAdded")
                         if (titleLbl.text!.isEmpty) {
                             note.title = "No Title"
                         }
                         else{
                           //  note.title = titleLbl.text!
                         }
                         note.text = txtView.text!
                      let imageData = showImg.image!.pngData() as NSData?
                         note.image = imageData as Data?
                        
                         note.notebook = self.notebook
                     }
                     
                     do {
                         try context.save()
                         print("Note Saved!")
                         
                         
                         // show an alert box
                         let alertBox = UIAlertController(title: "Saved!", message: "Save Successful.", preferredStyle: .alert)
                         alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                         self.present(alertBox, animated: true, completion: nil)
                     }
                     catch {
                         print("Error saving note in Edit Note screen")
                         
                         // show an alert box with an error message
                         let alertBox = UIAlertController(title: "Error", message: "Error while saving.", preferredStyle: .alert)
                         alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                         self.present(alertBox, animated: true, completion: nil)
                     }
                     
                     if (userIsEditing == false) {
                         self.navigationController?.popViewController(animated: true)
                         //self.dismiss(animated: true, completion: nil)
                     }
                     
                     
          }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
