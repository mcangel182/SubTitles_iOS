//
//  RestApiManager.swift
//  SubTitles
//
//  Created by María Camila Angel on 24/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    
    static let sharedInstance = RestApiManager()
    //let baseURL = "https://subtitlesapp.herokuapp.com/api/"
    let baseURL = "https://lit-citadel-90055.herokuapp.com/api/"
    
    func getObras(onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "obras/"
        makeHTTPGetRequest(path: route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func getSubtitlesObra(id: String, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "subtitlesDeObra/" + id + "/"
        makeHTTPGetRequest(path: route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func login(username: String, password: String, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "login/"
        let postString = "usuario="+username+"&contrasenia="+password
        makeHTTPPostRequest(path: route, postString: postString, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }

    func register(username: String, password: String, onCompletion: @escaping (JSON) -> Void) {
        let route = baseURL + "registro/"
        let postString = "usuario="+username+"&contrasenia="+password
        makeHTTPPostRequest(path: route, postString: postString, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    // MARK: Perform a GET Request
    private func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                onCompletion(json, error as NSError?)
            } else {
                onCompletion(JSON.null, error as NSError?)
            }
        })
        task.resume()
    }
    
    // MARK: Perform a POST Request
    private func makeHTTPPostRequest(path: String, postString: String, onCompletion: @escaping ServiceResponse) {
        let url = URL(string: path)
        var request = URLRequest(url: url!)
        
        // Set the method to POST
        request.httpMethod = "POST"
        
        do {
            // Set the POST body for the request
            request.httpBody = postString.data(using: .utf8)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if let jsonData = data {
                    let json:JSON = JSON(data: jsonData)
                    onCompletion(json, nil)
                } else {
                    onCompletion(JSON.null, error as NSError?)
                }
            })
            task.resume()
        } catch {
            // Create your personal error
            onCompletion(JSON.null, nil)
        }
    }
}
