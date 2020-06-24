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

class EditNotesViewController: UIViewController,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBOutlet weak var txttitle: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var notesImageView: UIImageView!
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    var recordingSession:AVAudioSession!
    var audioRecoreder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    var numberOfRecords:Int = 0
    
    @IBAction func record(_ sender: Any) {
        
        //check if audio recorder is active
        if  audioRecoreder == nil  {
            numberOfRecords += 1
            let filname = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),AVSampleRateKey: 12000,AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            // start audio recording
            do {
                audioRecoreder = try AVAudioRecorder(url: filname,settings: settings)
                audioRecoreder.delegate = self
                audioRecoreder.record()
                
                recordBtn.setTitle("Stop recording", for: .normal)
            } catch  {
                displayAlert(title: "Error!", message: "Recording Failed!!")
            }
            
        }
        else{
            
            //stop recording
            audioRecoreder.stop()
            audioRecoreder = nil
            
            UserDefaults.standard.set(numberOfRecords,forKey: "myNumber")
            myTableView.reloadData()
            recordBtn.setTitle("Make a VoiceNote", for: .normal)
        }
    }
    
    var latitudeString:String = ""
          var longitudeString:String = ""
    // MARK: -- variables
          var note:Note!
          var notebook : Notebook?
          var userIsEditing = true
         var old = true
    // MARK: -- database
        var context:NSManagedObjectContext!
        
  

    
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
    
        recordingSession = AVAudioSession.sharedInstance()
        
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber ") as? Int {
            numberOfRecords = number
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission{(hasPermission) in
            if hasPermission{
                print("Accepted")
            }
        }
        navigationController?.navigationBar.barTintColor = UIColor.green

    
    
          guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
          context = appDelegate.persistentContainer.viewContext
          
          if (userIsEditing == true) {
              print("Editing an existing note")
              txttitle.text = note.title!
              textView.text = note.text!
    self.notesImageView.image = UIImage(data: note.image! as Data)
             // lblLat.text = String(note.lat)
             // lblLong.text = String(note.long)
             // btnloc.isHidden = false
          }
          else {
              print("Going to add a new note to: \(notebook!.name!)")
              textView.text = ""
           //   btnloc.isHidden = true
          }
         // determineMyCurrentLocation()
          

          // Do any additional setup after loading the view.
    }
    
    @IBAction func selectimage(_ sender: UIButton) {
        
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
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
    }
    
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
      }
      
      override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
             //determineMyCurrentLocation()
         }
      
         
         func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
             let userLocation:CLLocation = locations[0] as CLLocation
            
             note.lat = userLocation.coordinate.latitude
             note.long = userLocation.coordinate.longitude
             print("user latitude = \(userLocation.coordinate.latitude)")
             print("user longitude = \(userLocation.coordinate.longitude)")
         }
         
         func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
         {
             print("Error \(error)")
         }
    
    
    
    
    @IBAction func savenotes(_ sender: UIBarButtonItem) {
        
        
                    // determineMyCurrentLocation()
                     if (textView.text!.isEmpty) {
                         print("Please enter some text")
                         return
                     }
                     
                     
                     if (userIsEditing == true) {
                         note.text = textView.text!
                     }
                     else {
                         
                         // create a new note in the notebook
                         self.note = Note(context:context)
                         note.setValue(Date(), forKey:"dateAdded")
                         if (txttitle.text!.isEmpty) {
                             note.title = "No Title"
                         }
                         else{
                             note.title = txttitle.text!
                         }
                         note.text = textView.text!
                      let imageData = notesImageView.image!.pngData() as NSData?
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
        
    
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

    //get path
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //display alert
    func displayAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert,animated: true,completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
     
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch
        {
            
        }
    }
}
