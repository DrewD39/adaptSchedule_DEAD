//
//  MenuController.swift
//  Test2_Drew
//
//  Created by Drew Davis on 6/13/18.
//  Copyright © 2018 Drew. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {

    var picker: UIDatePicker = UIDatePicker();
    
    var alert: UIAlertController?
    
    var startTime: Int = 0 // start time in minutes
    var activityOptions: [String] = []
    var minDurs: [String] = []
    var maxDurs: [String] = []
    
    var selectionActNum = -1
    var selectionDuration = 0 // time of activity in minutes
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // section 0: activity selection
        // section 1: schedule options
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // activity selection section
            return activityOptions.count
        case 1: // schedule options section
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: // activity selection section
            return "Activity Selection"
        case 1: // schedule options section
            return "Schedule Options"
        default:
            return ""
        }
    }

    /*
     * Populate the cell at indexPath with the cell returned by this function
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell
        
        switch indexPath.section {
        case 0: // activity selection section
            cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
            cell.textLabel?.text = activityOptions[indexPath.row]
            
            // if there is only 1 possible duration, display only once
            if minDurs[indexPath.row] == maxDurs[indexPath.row] {
                cell.detailTextLabel?.text = minDurs[indexPath.row]+" minutes"
            } // else if a range of durations, show range
            else {
                cell.detailTextLabel?.text = String(minDurs[indexPath.row])+" to "+String(maxDurs[indexPath.row])+" minutes"
            }
            
            break
            
        case 1: // schedule options section
            cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Add Activity"
                break
            case 1:
                cell.textLabel?.text = "Remove Activity"
                break
            case 2:
                cell.textLabel?.text = "Advanced Options"
                break
            default:
                break
            }
            break
            
        default:
            cell = UITableViewCell()
        }
        
        return cell

    }
    
    // This function called when user clicks an item in the tableview
    // You should only be able to select the rows in section 0 (activity selection section)
    // no features other than activity selection are implemented yet
    // If an attempt to selct something else, show a popup informing the user it is not yet implemented
    override public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        // in not in activity selection section
        if indexPath.section != 0 {
            
            // alert user with popup that this feature is not yet implemented
            let alert = UIAlertController(title: "Warning", message: "This feature has not yet been implemented.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Resume", style: .default, handler: nil))
            self.present(alert, animated: true)
            return nil
        }
        // if in activity section
        if indexPath.section == 0 {
            selectionActNum = indexPath.row // if an actiivity was selected, save its number for later access
            
            if activityOptions[indexPath.row] == "idle" {
                
                // popover alert code
                showTimePopover()
                
                
                
    //            // simple alert code
    //            let alert = UIAlertController(title: "", message: "How long would you like to perform this activity for?", preferredStyle: .alert)
    //            alert.addTextField()
    //            let anAction = UIAlertAction(title: "Enter", style: .default, handler: { (_) in
    //                do {
    //                    self.selectionDuration = Int(alert.textFields![0].text!)!
    //                    if self.selectionDuration < Int(self.minDurs[indexPath.row])! || self.selectionDuration > Int(self.maxDurs[indexPath.row])! {
    //                        // illegal selection
    //                        print("illegal duartion choice")
    //                        self.selectionDuration = 5
    //                    }
    //                } catch {
    //                    print("incompatable duration entered")
    //                }
    //            })
    //            alert.addAction(anAction)
    //            self.present(alert, animated: true, completion: nil)
                
                
                
                
            } else {
                selectionDuration = Int(minDurs[indexPath.row])!
            }
        
        }
        return indexPath
    }
    
    
    //optional func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func showTimePopover() {
        let title = "Select valid end time"
        let message = "\n\n\n\n\n\n\n\n\n\n";
        alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet);
        alert!.isModalInPopover = true;
        
        let popover = alert!.popoverPresentationController
        popover?.sourceView = alert!.view
        popover?.sourceRect = CGRect(x: 150, y: 64 + 50*(selectionActNum+1), width: 1, height: 1) //50*(selectionActNum+1)
//        popover?.barButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 300, y: 200 + 50*(selectionActNum+1), width: 1000, height: 1000)))
        
        
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        let pickerFrame: CGRect = CGRect(x: 17, y: 52, width: 270, height: 100); // CGRectMake(left), top, width, height) - left and top are like margins
        picker = UIDatePicker(frame: pickerFrame);
        picker.datePickerMode = .countDownTimer;
        picker.minuteInterval = 5 // only show options at 5 minute intervals
//        let currentServDate = Date(timeInterval: Double(startTime)*60, since: Calendar.current.startOfDay(for: Date()) )
//        picker.minimumDate = Date( timeInterval: 5 * 60,                             since: currentServDate )  // minimum idle time (in seconds)
//        picker.maximumDate = Date( timeInterval: Double(self.maxDurs[actNum])! * 60, since: currentServDate ) // max idle time (in seconds)
//        picker.Timer = 300.0 // start at 5 minutes
        
        
        // picker.countDownDuration  ==  currently selected time in seconds
        
        
        //set the pickers datasource and delegate
//        picker.delegate = self;
//        picker.dataSource = self;
        
        //Add the picker to the alert controller
        alert!.view.addSubview(picker);
        
        //Create the toolbar view - the view witch will hold our buttons
        let toolFrame = CGRect(x: 17, y: 164 , width: 270, height: 45);
        let toolView: UIView = UIView(frame: toolFrame);
        
        
        //add buttons to the view
        let buttonTimeSelectFrame: CGRect = CGRect(x:85, y:7, width:100, height:30); //size & position of the button as placed on the toolView
        
        //Create the Select button & set the title
        let buttonTimeSelect: UIButton = UIButton(frame: buttonTimeSelectFrame);
        buttonTimeSelect.setTitle("Select", for: UIControlState.normal);
        buttonTimeSelect.setTitleColor(UIColor.blue, for: UIControlState.normal);
        toolView.addSubview(buttonTimeSelect); //add to the subview
        
        //Add the tartget. In my case I dynamicly set the target of the select button
        buttonTimeSelect.addTarget(self, action: #selector( selectPicker ), for: UIControlEvents.touchDown);
        
        //add the toolbar to the alert controller
        alert!.view.addSubview(toolView);
        
        self.present(alert!, animated: true, completion: nil);
        //        let ac = UIAlertController(title: "Hello!", message: "This is a test.", preferredStyle: .actionSheet)
        //        let popover = ac.popoverPresentationController
        //        popover?.sourceView = tableView
        //        popover?.sourceRect = CGRect(x: 32, y: 44, width: 64, height: 64)
        //
        //        present(ac, animated: true)
        
    }

    // action to perform when the cancel button is clicked on the picker time select popover
    @objc func selectPicker(sender: UIButton){
        print("Time selected");
//        let currentServDate = Date(timeInterval: Double(startTime)*60, since: Calendar.current.startOfDay(for: Date()) )
//        selectionDuration = Int(currentServDate.timeIntervalSince(picker.date)) / 60 // need to set duration based on final picker time (in seconds) and convert to minutes
        selectionDuration = Int(picker.countDownDuration / 60) // time to perform activity in minutes
        alert!.dismiss(animated: true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }

    
}



