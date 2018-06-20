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
    
    // for now, use a random int as the client ID (to prevent randos from internet from accessing)
    let ID = String( arc4random_uniform(_:10000000) )
    var urlString: String
    let url: URL?
    
    var JSON_encoder: JSONEncoder
    
    // These are the pieces of info that will be recieved on each reply from the server
    var currentInfo: fromServer = fromServer()
    


    /*
     * Constructor
    */
    init() {
        do {
            
            JSON_encoder = JSONEncoder()
            JSON_encoder.outputFormatting = .prettyPrinted
            
            // URL to access server at, appended by client ID to validate access
            urlString = "http://35.3.95.42:8080/" + ID
            
            url = URL(string: urlString)
            
            requestPOST = URLRequest(url: url!)
            requestPOST.httpMethod = "POST"
            requestGET = URLRequest(url: url!)
            requestGET.httpMethod = "GET"
            
            
            // tell server you are starting a new session
            var aPut = putCMD()
            aPut.infoType = "startup"
            aPut.clientID = ID
            let someData = try JSON_encoder.encode( aPut )
            requestPOST.httpBody = someData
            makeAReq(req: requestPOST)
            
        } catch {
            print("Error: client init() failed")
        }
    }
    
    
    /*
     * Destructor
    */
    deinit {
    }
    
    
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
            
            print("\nJSON sent to server:")
            print(thePut)
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    /*
     * Make a Get or Put request to the server and get the response from the server
     * Server expected response JSON format defined by fromServer struct
     * This response format should match the JSON format seen in the server code
     */
    func makeAReq(req: URLRequest) {
        // make the specific request and then handle the reply (data, response, error)
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if error != nil {
                print("nill error:")
                print(error!.localizedDescription)
            }
            
            // get the data from inside the reply
            guard let data = data else { return }
            do {
                let servData = try JSONDecoder().decode(fromServer.self, from: data)
                
                // if the reply info type is not blank, parse the data
                if (servData.infoType != "") {
                    print("\nJSON received from server:")
                    self.currentInfo.infoType = servData.infoType!;                     print("  infoType: ", terminator:"");        print(servData.infoType!)
                    self.currentInfo.startTime = servData.startTime!;                   print("  startTime: ", terminator:"");       print(servData.infoType!)
                    self.currentInfo.nextActivities = servData.nextActivities!;         print("  nextActivities: ", terminator:"");  print(servData.nextActivities!)
                    self.currentInfo.nextActsMinDur = servData.nextActsMinDur!;         print("  actsMinDur: ", terminator:"");      print(servData.nextActsMinDur!)
                    self.currentInfo.nextActsMaxDur = servData.nextActsMaxDur!;         print("  actsMaxDur: ", terminator:"");      print(servData.nextActsMaxDur!)
                    self.currentInfo.debugInfo = servData.debugInfo!;                   print("  debugInfo: ", terminator:"");       print("~suppressed for readability~")//print(servData.debugInfo!)
                }
                
            } catch let error as NSError {
                print("\nmakeAReq error:")
                print(error)
            }
            
            }.resume()
    }
    
    
    /*
     * Every 200 ms poll the server for any new requests using GET requests
     */
    func heartbeat() {
        while(true) {
            self.makeAReq(req: self.requestGET)
            usleep(200000) // microseconds
            if self.currentInfo.infoType == "startup" {return;}
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
    var activityDuration = ""
    var debugInfo = [""]
}

// These struct variables need to match the names seen in the JSON object
// This structure format should match the reply format on the server side
struct fromServer: Codable {
    // do not make these optional, because we want to throw error if some of the data is missing
    // (unecesary components should be included as blank strings / empty vectors)
    var infoType : String?
    var startTime: String?
    var nextActivities : [String]?
    var nextActsMinDur : [String]?
    var nextActsMaxDur : [String]?
    var remActivities  : [String]?
    var remMinDurs     : [String]?
    var remMaxDurs     : [String]?
    var remMinStarts   : [String]?
    var remMaxEnds     : [String]?
    var debugInfo      : [String]?
    
    init() {
        infoType = ""
        startTime = ""
        nextActivities = []
        nextActsMinDur = []
        nextActsMaxDur = []
        remActivities  = []
        remMinDurs     = []
        remMaxDurs     = []
        remMinStarts   = []
        remMaxEnds     = []
        debugInfo      = []
    }
}

