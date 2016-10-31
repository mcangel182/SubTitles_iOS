//
//  ObraViewController.swift
//  SubTitles
//
//  Created by María Camila Angel on 25/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation
import EventKit
import EventKitUI

class ObraViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var obra: ObraObject?
    var subtitles = [SubtitlesObject]()

    let filemanager = FileManager.default
    
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var synopsisText: UITextView!
    @IBOutlet weak var typeText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var languageText: UILabel!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var pickerSubtitles: UIPickerView!
    @IBOutlet weak var downloadBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear detalle obra")
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = obra?.nombre
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerSubtitles.dataSource = self;
        self.pickerSubtitles.delegate = self;

        self.nombreLabel.text = obra!.nombre
        self.synopsisText.text = obra!.info
        self.typeText.text = obra!.tipo
        self.dateText.text = obra!.fecha
        self.languageText.text = obra!.idioma_original
        self.scoreText.text = obra!.calificacion
        
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ObraViewController.addToCalendar))
        self.navigationItem.rightBarButtonItem = button

        loadSubtitles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSubtitles() {
        RestApiManager.sharedInstance.getSubtitlesObra(id: obra!.id, onCompletion: {(json: JSON) in
            print("JSON: \(json)")
            if let results = json.array {
                for entry in results {
                    self.subtitles.append(SubtitlesObject(json: entry))
                }
                DispatchQueue.main.async {
                    print("cargo subs")
                    if results.count == 0 {
                        self.downloadBtn.isEnabled = false
                    }
                    self.pickerSubtitles.reloadAllComponents()
                }
            }
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subtitles.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return subtitles[row].idioma
    }

    @IBAction func downloadSubtitles(_ sender: AnyObject) {
        let row = pickerSubtitles.selectedRow(inComponent: 0)
        let selectedSubtitle = subtitles[row]
        let url = selectedSubtitle.url
        let urlOriginales = self.obra!.url
        let folderName = (obra?.nombre)!
        let fileName = folderName + "/" + selectedSubtitle.idioma + ".txt"
        if let URL = URL(string: url!) {
            downloadFile(URL, folderName: folderName, fileName: fileName)
        }
        if let URL = URL(string: urlOriginales!) {
            downloadFile(URL, folderName: (obra?.nombre)!, fileName: (obra?.nombre)! + "/originales.txt")
        }
        
    }
    
    func downloadFile(_ url: URL, folderName: String, fileName: String) {
        let task = URLSession.shared.downloadTask(with: url, completionHandler: { location, response, error in
            guard location != nil && error == nil else {
                print(error)
                return
            }
            
            let fileManager = FileManager.default
            let documents = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            do {
                
                //Revisar si existe el directorio de la obra
                let folderPath = documents.appendingPathComponent(folderName).path
                if !fileManager.fileExists(atPath: folderPath) {
                    try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
                    print("Crea directorio")
                }
                
                //Revisar si ya existe el archivo
                let fileURL = documents.appendingPathComponent(fileName)
                print(fileURL.path)
                if fileManager.fileExists(atPath: fileURL.path) {
                    print("File exists")
                    do {
                        let readFile = try String(contentsOfFile: fileURL.path, encoding: String.Encoding.utf8)
                        print("\(readFile)")
                        DispatchQueue.main.async(execute: {
                            let alertController = UIAlertController(title: "SubTitles", message:"The subtitles were already downloaded", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        })
                        // the above prints "some text"
                    } catch let error as NSError {
                        print("Error: \(error)")  
                    }  
                } else {
                    try fileManager.moveItem(at: location!, to: fileURL)
                    DispatchQueue.main.async(execute: {
                        let alertController = UIAlertController(title: "SubTitles", message:"The subtitles have been downloaded", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                    print("guardo")
                }
                
            } catch {
                print("papaya error")
                print(error)
            }
        }) 
        task.resume()
    }
    
    func addToCalendar(){
        
        print("entra a calendario")
        
        let eventStore : EKEventStore = EKEventStore()
        
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: (self.obra?.fecha)!)
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = (self.obra?.nombre)!
                
                event.startDate = date!
                event.endDate = date!.addingTimeInterval(60*60*2)
                event.calendar = eventStore.defaultCalendarForNewEvents
                do{
                    try eventStore.save(event, span: .thisEvent, commit: true)
                    print("Saved Event")
                    DispatchQueue.main.async(execute: {
                        let alertController = UIAlertController(title: "SubTitles", message:"The event has been saved to your calendar", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                    
                    
                } catch {
                    print("Ocurrio un error")
                }
                
            } else {
                print("access denied")
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
