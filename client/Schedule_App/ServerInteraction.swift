//
//  ServerInteraction.swift
//  Schedule_App
//
//  Created by Drew Davis on 5/22/18.
//  Copyright © 2018 Drew. All rights reserved.
//
// Code taken from main.swift of Drew_cmdLine project

import Foundation


class client {
    
    var requestPOST: URLRequest
    var requestGET: URLRequest
    
    
    let ID = String( arc4random_uniform(_:10000000) )
    var urlString: String
    var JSON_encoder: JSONEncoder
    
    let url: URL?
    
    // var cmdStr: String?
    // var toPrintFromServer: String
    var infoType : String?
    var nextActivites : [String]?
    var maxIdleTime : String?
    var debugInfo : [String]?


    /*
     * Constructor
    */
    init() {
        do {
            //toPrintFromServer = ""
            infoType = ""
            nextActivites = []
            maxIdleTime = ""
            debugInfo = []
            
            JSON_encoder = JSONEncoder()
            JSON_encoder.outputFormatting = .prettyPrinted
            //var cmdStr = ""
            
            //let ID = String( arc4random_uniform(_:10000000) )
            
            //Implementing URLSession
            urlString = "http://localhost:8080/" + ID // where the data is stored
            //            guard let url = URL(string: urlString) else {
            //                throw MyError.runtimeError("on no")
            //            } // convert string to URL class
            
            url = URL(string: urlString)
            
            requestPOST = URLRequest(url: url!)
            requestPOST.httpMethod = "POST"
            requestGET = URLRequest(url: url!)
            requestGET.httpMethod = "GET"
            
            
            // tell server you are starting a new session
//            // TXT bsased JSON format to send to server
//            var someData = try JSON_encoder.encode(
//                putCMD(cmd: "cmd",value: "RESTART",clientID: ID))
            //GUI based JSON format to send to server
//            var aPut = putCMD()
//            aPut.infoType = "startup"
//            aPut.clientID = ID
//            
//            let someData = try JSON_encoder.encode( aPut )
//            requestPOST.httpBody = someData
//            
//            makeAReq(req: requestPOST)
        } catch {
            print("Error: client init() failed")
        }
    }
    
    
    /*
     * Destructor
    */
    deinit {
        infoType = ""
        nextActivites = []
        maxIdleTime = ""
        debugInfo = []
    }
    
    
//    // old method for text-based interface
//    func sendStrToServer(str: String) {
//        var aReq: URLRequest
//        aReq = URLRequest(url: self.url!)
//        aReq.httpMethod = "POST"
//
//        // tell server you are starting a new session
//        do {
//            let aData = try JSON_encoder.encode(
//            putCMD(cmd: "cmd",value: str,clientID: self.ID))
//            aReq.httpBody = aData
//            makeAReqTXT(req: aReq)
//        } catch let error as NSError {
//            print(error)
//        }
//    }
    
    /*
     * Send a JSON file to the server using internal methods
     * This should be called by GUI items upon user interaction
    */
    func sendStructToServer(_ thePut: putCMD) {
        do {
            let json = try JSON_encoder.encode(thePut)
            
            var aReq: URLRequest
            aReq = URLRequest(url: self.url!)
            aReq.httpMethod = "POST"
            aReq.httpBody = json
            
            makeAReq(req: aReq)
        } catch let error as NSError {
            print(error)
        }
    }
    
    
//    // method for text-based UI
//    /*
//     * Make a Get or Put request to the server and get the response from the server
//     * Server expected response JSON format defined by fromServer struct
//    */
//    func makeAReq(req: URLRequest) {
//        URLSession.shared.dataTask(with: req) { (data, response, error) in
//            if error != nil {
//                print("nill error:")
//                print(error!.localizedDescription)
//            }
//
//            // These struct variables need to match the names seen in the JSON object
//            struct fromServer: Codable {
//                let toPrint: String
//            }
//
//            // check for toPrint values in the response JSON
//            guard let data = data else { return }
//
//            do {
//                let servData = try JSONDecoder().decode(fromServer.self, from: data)
//                //print("to print from the server: " + servData.toPrint)
//                if servData.toPrint != "" {
//                    print(servData.toPrint)
//                    self.toPrintFromServer += servData.toPrint
//                }
//
//            } catch let error as NSError {
//                print(error)
//            }
//
//            }.resume()
//        //End implementing URLSession
//    }
    
    /*
     * Make a Get or Put request to the server and get the response from the server
     * Server expected response JSON format defined by fromServer struct
     * ^^ this response format should match the JSON format seen in the server code
     */
    // method for text-based UI
    func makeAReq(req: URLRequest) {
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if error != nil {
                print("nill error:")
                print(error!.localizedDescription)
            }
            
            // These struct variables need to match the names seen in the JSON object
            struct fromServer: Codable {
                // do not make these optional, because we want to throw error if some of the data is missing
                // (unecesary components should be included as blank strings / empty vectors)
                var infoType : String
                var nextActivities : [String]
                var maxIdleTime : String
                var debugInfo : [String]
            }
            
            // check for toPrint values in the response JSON
            guard let data = data else { return }
            
            do {
                let servData = try JSONDecoder().decode(fromServer.self, from: data)
                // do something with servData
                self.infoType = servData.infoType
                self.nextActivites = servData.nextActivities
                self.maxIdleTime = servData.maxIdleTime
                
            } catch let error as NSError {
                print(error)
            }
            
            }.resume()
        //End implementing URLSession
    }
    
    
    /*
     * Every 200 ms poll the server for anything to print using GET requests
     */
    func heartbeat() {
        while(true) {
            self.makeAReq(req: self.requestGET)
            usleep(200000) // microseconds
            if self.infoType == "startup" {return;}
        }
    }
    
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
}



/*
 * Structure of JSON format sent to the server
 * Should be the same format as the JSONs passed into sendJSONtoServer()
 */
struct putCMD: Codable {
    var clientID = ""
    var infoType = ""  // options: startup / ganttRequest / confirmActivity / addActivity / removeActivity / editActivty
    var activityName = ""
    var debugInfo = [""]
    
    //        var cmd: String
    //        var value: String
    //        var clientID: String
}

// sample initialization
//var aPut = putCMD()
//aPut.clientID = ""
//aPut.infoType = ""  // options: startup / ganttRequest / confirmActivity / addActivity / removeActivity / editActivty
//activityName = ""
//aPut.debugInfo = [""]

