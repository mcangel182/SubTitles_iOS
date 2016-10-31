//
//  ObrasTableViewController.swift
//  SubTitles
//
//  Created by María Camila Angel on 24/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit
import SwiftyJSON

class ObrasTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var obras = [ObraObject]()
    var obrasSearch = [ObraObject]()
    let textCellIdentifier = "TextCell"
    var searchActive = false
    weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var searchBar: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView
        self.searchBar.delegate = self
        //self.tableView.register(UINib(nibName: "ObraTableViewCell", bundle: nil), forCellReuseIdentifier: "ObraCell")
        
        loadObras()
        
    }
    
    func loadObras() {
        activityIndicatorView.startAnimating()
        RestApiManager.sharedInstance.getObras{ (json: JSON) in
            print("JSON: \(json)")
            if let results = json.array {
                for entry in results {
                    self.obras.append(ObraObject(json: entry))
                }
                DispatchQueue.main.async {
                    print("cargo obras")
                    self.activityIndicatorView.stopAnimating()
                    self.tableView.reloadData()
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        obrasSearch = obras.filter({ (text) -> Bool in
            let tmp: NSString = text.nombre as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(obrasSearch.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchActive {
            return obrasSearch.count
        }
        else {
            return obras.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ObraCell"
        print(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if let obraCell = cell as? ObraTableViewCell{
            if searchActive {
                let obra = obrasSearch[indexPath.row]
                obraCell.nombre.text = obra.nombre
                obraCell.idioma_original.text = obra.idioma_original
            }
            else {
                let obra = obras[indexPath.row]
                obraCell.nombre.text = obra.nombre
                obraCell.idioma_original.text = obra.idioma_original
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obra = obras[indexPath.row]
        self.performSegue(withIdentifier: "DetalleObra", sender: obra)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DetalleObra" {
            if let obraViewController = segue.destination as? ObraViewController {
                obraViewController.obra = sender as? ObraObject
            }
        }
    }
 

}
