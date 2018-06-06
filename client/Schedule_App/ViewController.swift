//
//  ViewController.swift
//  Schedule_App
//
//  Created by Drew Davis on 5/21/18.
//  Copyright © 2018 Drew. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    var aClient: client?
    var timer: DispatchSourceTimer?
    
    
    //MARK: Properties
//    @IBOutlet weak var titleText: UILabel!
//    @IBOutlet weak var textInput: UITextField!
    
    @IBOutlet weak var MainTextIn: UITextField!
    @IBOutlet weak var MainTextDisplay: UITextView!
    @IBOutlet weak var ActivityOptionsStack: UIStackView!
    @IBOutlet weak var UndoLastButton: UIButton!
    @IBOutlet weak var VisualizeScheduleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        //textInput.delegate = self
        MainTextIn.delegate = self
        
        self.aClient = client()
        DispatchQueue.global(qos: .background).async {
            //self.aClient!.continuouslyGetInOut() // wont leave this point until connection with server terminated
            self.aClient!.heartbeat() // will update the member variables of aClient in background when the server sends info
        }
        
        DispatchQueue.global(qos: .background).async {
//            var strFromServ = ""
            var buttons: [UIButton] = []
            
            while (true) {
                sleep(1)
                if (self.aClient!.infoType != "") {
                    
                    
                    // Update the UI on the main thread
                    DispatchQueue.main.async() {
//                        strFromServ = self.aClient!.toPrintFromServer
//                        self.aClient!.toPrintFromServer = ""
                        let infoTypeFromServ = self.aClient!.infoType!; self.aClient!.infoType = ""
                        let nextActsFromServ = self.aClient!.nextActivites!; self.aClient!.nextActivites = []
                        let maxIdleTimeFromServ = self.aClient!.maxIdleTime!; self.aClient!.maxIdleTime = ""
                        let debugInfoFromServ = self.aClient!.debugInfo!; self.aClient!.debugInfo?.removeAll()
                        
                        
                        
                        // remove old button activity options
                        for index in 0..<buttons.count {
                            buttons[index].removeFromSuperview()
                        }
                        
                        
                        self.MainTextDisplay.text = self.MainTextDisplay.text! + infoTypeFromServ + " " + maxIdleTimeFromServ
                        let range = NSMakeRange(self.MainTextDisplay.text.count - 1, 1);
                        self.MainTextDisplay.scrollRangeToVisible(range)

                        
                        var strActs = nextActsFromServ // array of activities
                        var firstActLine = 9999999999999
                        
                        if strActs.count > 0 {
                            buttons = []
                            for index in 0...strActs.count-1 {
                                let button = UIButton(frame: .zero)
                                button.setTitleColor(.black, for: .normal)
                                button.setTitle(strActs[index], for: .normal)
                                button.layer.borderColor = UIColor.gray.cgColor
                                button.layer.borderWidth = 1.0
                                button.translatesAutoresizingMaskIntoConstraints = false
                                self.ActivityOptionsStack.addSubview(button)
//                                button.frame.size.width = 200.0
//                                    = CGSize(width:200, height:100)
                                let widthContraints =  NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 150)
                                let heightContraints = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50)
                                NSLayoutConstraint.activate([heightContraints,widthContraints])
                                button.addTarget(self, action: #selector(self.activityButtonAction), for: .touchUpInside)
                                buttons.append(button)
                            }
                            
                            for index in 0...strActs.count-1 {
                                let button = buttons[index]
                                if index == 0 {
                                    button.leadingAnchor.constraint(equalTo: self.ActivityOptionsStack.leadingAnchor, constant: 0.0).isActive = true
                                    button.topAnchor.constraint(equalTo: self.ActivityOptionsStack.topAnchor, constant: 0.0).isActive = true
                                } else if (index == 1) {
                                    let preButton = buttons[0]
                                    button.trailingAnchor.constraint(equalTo: self.ActivityOptionsStack.trailingAnchor, constant: 0).isActive = true
                                    button.topAnchor.constraint(equalTo: preButton.topAnchor, constant: 0).isActive = true
                                } else if (index % 2 == 1) { // odd indices go on right side
                                    let preButton = buttons[index - 2]
                                    button.leadingAnchor.constraint(equalTo: preButton.leadingAnchor, constant: 0).isActive = true
                                    button.topAnchor.constraint(equalTo: preButton.bottomAnchor, constant: 10).isActive = true
                                } else if (index % 2 == 0) { // even indices go on left side
                                    let preButton = buttons[index - 2]
                                    button.trailingAnchor.constraint(equalTo: preButton.trailingAnchor, constant: 0).isActive = true
                                    button.topAnchor.constraint(equalTo: preButton.bottomAnchor, constant: 10).isActive = true
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // called upon releasing first responder status (AKA right after testFieldShouldReturn returns)
    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.aClient!.sendStrToServer(str: MainTextIn.text!) // TXT-based interface command
        
        var aPut = putCMD()
        aPut.clientID = self.aClient!.ID
        aPut.infoType = "confirmActivity"
        aPut.activityName = self.MainTextDisplay.text
        self.aClient!.sendStructToServer( aPut )
        
        self.MainTextDisplay.text = ""
        MainTextIn.text = ""
    }
    
    //MARK: Actions
//    @IBAction func setDefaultTextButton(_ sender: UIButton) {
//        titleText.text = "Default Text"
//    }
    
    @IBAction func activityButtonAction(_ sender: UIButton) {

        var aPut = putCMD()
        aPut.clientID = self.aClient!.ID
        aPut.infoType = "confirmActivity"
        aPut.activityName = sender.titleLabel!.text!
        self.aClient!.sendStructToServer(aPut)
        
        self.MainTextDisplay.text = ""
    }
    
//    // no longer a feature in GUI interface
//    @IBAction func undoButtonAction(_ sender: UIButton) {
//        self.aClient!.sendStrToServer(str: "U")
//        self.MainTextDisplay.text = ""
//    }
    
    
}


extension UISegmentedControl {
    func replaceSegments(segments: Array<String>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
        }
    }
}
