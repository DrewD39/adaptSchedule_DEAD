//
//  ViewController.swift
//  Schedule_App
//
//  Created by Drew Davis on 5/21/18.
//  Copyright © 2018 Drew. All rights reserved.
//

import UIKit

// All elements in the main screen are contained in this view
class ViewController: UIViewController, UITextFieldDelegate {
    // client class handles all client-server interaction
    var aClient: client?
    
    // menuDelegate is tableViewController to control left side menu of main screen
    var menuDelegate = MenuController(style: .grouped)
    
    
    //MARK: Properties
    @IBOutlet var SideMenu: UITableView!
    @IBOutlet weak var ConfirmActButton: UIButton!
    
    
    // Called whenever this view (main screen) opens to the user (including app startup)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the sideMenu tableView as a child view
        addChildViewController(menuDelegate)
        //        view.addSubview(menuDelegate.view)
        menuDelegate.didMove(toParentViewController: self)
        
        // Set the sideMenu delegate and dataSource to MenuController (sublass of TableViewController)
        SideMenu.delegate = menuDelegate
        SideMenu.dataSource = menuDelegate
        
        // initialize client
        self.aClient = client()
        
        // In the background, the client should continuously send heartbeat GET messages to the server
        // Heartbeat function will update the member variables of aClient in background whenever the server replies with new info
        DispatchQueue.global(qos: .background).async {
            self.aClient!.heartbeat()
        }
        
        // In the background, changes to the client should be pulled up here into the controller
        DispatchQueue.global(qos: .background).async {
            while (true) {
                usleep(200000) // wait microseconds
                // infoType will be non-empty if client has received message of significance
                if (self.aClient!.infoType != "") {
                    // UI must be updated on the main queue (thread)
                    DispatchQueue.main.async() {
                        let infoTypeFromServ = self.aClient!.infoType!; self.aClient!.infoType = ""
                        let nextActsFromServ = self.aClient!.nextActivites!; self.aClient!.nextActivites = []
                        let maxIdleTimeFromServ = self.aClient!.maxIdleTime!; self.aClient!.maxIdleTime = ""
                        let debugInfoFromServ = self.aClient!.debugInfo!; self.aClient!.debugInfo?.removeAll()
                        
                        // update list of possible activities and trigger a sideMenu refresh
                        self.menuDelegate.activityOptions = nextActsFromServ
                        self.SideMenu.reloadData()

                    }
                }
            }
        }
    }

    // Auto-generated function to handle memory overuse
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Actions
    
    // This function is called when the 'confirm activity' button is clicked
    // Will take the label from the currently selected activity and send it to the server as the activity selection
    @IBAction func confirmActButtonClick(_ sender: UIButton) {
        var aPut = putCMD()
        aPut.clientID = self.aClient!.ID
        aPut.infoType = "confirmActivity"
        
        // if some activity has been selected
        if SideMenu.indexPathForSelectedRow != nil {
            
            // send the label of the currently selected activity
            aPut.activityName = menuDelegate.activityOptions[SideMenu.indexPathForSelectedRow!.row]
            
            // unselect the selection from the list
            SideMenu.deselectRow(at: SideMenu.indexPathForSelectedRow!, animated:false)
            
            // clear the list until new activity options are provided
            self.menuDelegate.activityOptions = []
            self.SideMenu.reloadData()
            
            // send request to server
            self.aClient!.sendStructToServer(aPut)
            
        } else { // if no actiivty was selected
            
            // create a pop-up informing user no activity was selected
            let alert = UIAlertController(title: "Error", message: "Select an activity before confirming.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Resume", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
    }
    
}




