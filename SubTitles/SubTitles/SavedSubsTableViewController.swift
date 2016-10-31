//
//  SavedSubsTableViewController.swift
//  SubTitles
//
//  Created by María Camila Angel on 27/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit

class SavedSubsTableViewController: UITableViewController {

    var savedsubs = [SavedSubObject]()
    let preferences = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewwillappear")
        
        print(preferences.object(forKey: "userId"))
        if preferences.object(forKey: "userId") == nil{
            self.navigationItem.rightBarButtonItem?.title = "Log In"
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Log Out"
        }
        
        self.tabBarController?.tabBar.isHidden = false
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        print("viewdidload")
        super.viewDidLoad()
        loadSavedSubs()
        self.refreshControl?.addTarget(self, action: #selector(SavedSubsTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Code to refresh table view
        print("refrescaaar")
        loadSavedSubs()
        refreshControl.endRefreshing()
    }
    
    func loadSavedSubs() {
        let fileManager = FileManager.default
        let documents = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: documents.path)!
        savedsubs = [SavedSubObject]()
        while let element = enumerator.nextObject() as? String {
            if element.hasSuffix(".txt") { // checks the extension
                print(element);
                let info = element.characters.split{$0 == "/"}.map(String.init)
                let nombre = info[0]
                let idioma = info[1].substring(to: info[1].characters.index(info[1].endIndex, offsetBy: -4))
                if (idioma != "originales"){
                    savedsubs.append(SavedSubObject(nombre: nombre, idioma: idioma, archivoTraduccion: element, archivoOriginal: nombre+"/originales.txt"))
                }
            }
        }
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if savedsubs.count == 0 {
            let noSubsLabel = UILabel(frame: CGRect(x:0, y:0, width:self.tableView.bounds.size.width, height:self.tableView.bounds.height))
            noSubsLabel.text = "No subs available"
            noSubsLabel.textColor = UIColor.gray
            noSubsLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noSubsLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        } else {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            self.tableView.backgroundView = nil
        }
        return savedsubs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SavedSubTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SavedSubTableViewCell
        let savedsub = savedsubs[indexPath.row]
        cell.obra.text = savedsub.nombre
        cell.idioma.text = savedsub.idioma
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let subABorrar = savedsubs[indexPath.row]
            let fileManager = FileManager.default
            let documents = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            do {
                try fileManager.removeItem(atPath: documents.path + "/" + subABorrar.archivoTraduccion)
                savedsubs.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
                let obra = subABorrar.archivoTraduccion.characters.split{$0 == "/"}.map(String.init)[0]
                let files = try fileManager.contentsOfDirectory(atPath: documents.path + "/" + obra);
                let count = files.count
                if(count==1){
                    try fileManager.removeItem(atPath: documents.path + "/" + obra)
                }
                
            } catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subs = savedsubs[indexPath.row]
        self.performSegue(withIdentifier: "MostrarSubtitulos", sender: subs)
    }
    
    @IBAction func logAction(_ sender: Any) {
        print("logaction")
        if(preferences.object(forKey: "userId") == nil){
            performSegue(withIdentifier: "MostrarLogin", sender: self);
        } else {
            print("hacer logout")
            preferences.removeObject(forKey: "userId")
            self.navigationItem.rightBarButtonItem?.title = "Log In"
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MostrarSubtitulos" {
            if let subtitlesViewController = segue.destination as? SubtitlesViewController {
                subtitlesViewController.subtitles = sender as? SavedSubObject
            }
        }
    }

}
