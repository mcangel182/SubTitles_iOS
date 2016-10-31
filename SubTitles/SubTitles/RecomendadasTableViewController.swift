//
//  RecomendadasTableViewController.swift
//  SubTitles
//
//  Created by Maria Camila Angel on 31/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit
import SwiftyJSON

class RecomendadasTableViewController: UITableViewController {
    
    var recomendadas = [ObraObject]()
    let preferences = UserDefaults.standard
    //weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        //tableView.backgroundView = activityIndicatorView
        //self.activityIndicatorView = activityIndicatorView
        self.refreshControl?.addTarget(self, action: #selector(RecomendadasTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        loadRecomendadas()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Code to refresh table view
        print("refrescaaar")
        loadRecomendadas()
        refreshControl.endRefreshing()
    }

    func loadRecomendadas(){
        recomendadas = [ObraObject]()
        if preferences.object(forKey: "userId") != nil {
            //activityIndicatorView.startAnimating()
            RestApiManager.sharedInstance.getRecomendadas(id: String(preferences.object(forKey: "userId") as! Int), onCompletion: { (json: JSON) in
                print("JSON: \(json)")
                if let results = json.array {
                    for entry in results {
                        self.recomendadas.append(ObraObject(json: entry))
                    }
                    DispatchQueue.main.async {
                        print("cargo obras")
                        //self.activityIndicatorView.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
                
            })
        }
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
        if recomendadas.count == 0 {
            let noSubsLabel = UILabel(frame: CGRect(x:0, y:0, width:self.tableView.bounds.size.width, height:self.tableView.bounds.height))
            if preferences.object(forKey: "userId") == nil {
                noSubsLabel.text = "Please log in to see your suggested plays"
            } else {
                noSubsLabel.text = "No suggested plays found"
            }
            noSubsLabel.textColor = UIColor.gray
            noSubsLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noSubsLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        } else {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            self.tableView.backgroundView = nil
        }
        return recomendadas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ObraCell"
        print(indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let obraCell = cell as? ObraTableViewCell{
            let obra = recomendadas[indexPath.row]
            obraCell.nombre.text = obra.nombre
            obraCell.idioma_original.text = obra.idioma_original
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obra = recomendadas[indexPath.row]
        print(obra.nombre)
        self.performSegue(withIdentifier: "DetalleObraRecomendada", sender: obra)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DetalleObraRecomendada" {
            if let obraViewController = segue.destination as? ObraViewController {
                obraViewController.obra = sender as? ObraObject
            }
        }
    }
    

}
