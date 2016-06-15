//
//  MenuViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/7/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit


@objc

// Define MenuViewControllerDelegate as a protocol with one required method
protocol DriverMenuViewControllerDelegate {
    func itemSelected()
}

class DriverMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var delegate: DriverMenuViewControllerDelegate?
    
    @IBOutlet var tableView: UITableView!
    
    var tableViewList = [String]()
    
    // Flags created and initialized
    var itemSelected: Bool = false
    var selectedRowNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewList.append("Switch to Rider")
        tableViewList.append("My Car")
        tableViewList.append("Settings")
        
        // Do any additional setup after loading the view.
    }
    
    // Prepare the view before it appears to the user
    override func viewWillAppear(animated: Bool) {
        
        if itemSelected {
            
            // Reload the table view data so that the selected sport name can be
            // colored in blue to indicate that it is the selected row.
            tableView.reloadData()
        }
        
        super.viewWillAppear(animated)
    }
    
    // Asks the data source to return the number of sections in the table view
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    // Asks the data source to return the number of rows in a section, the number of which is given
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewList.count
    }
    
    //-------------------------------------------------------------
    //         Prepare and Return a Table View Cell
    //-------------------------------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let rowNumber: Int = indexPath.row    // Identify the row number
        
        // Obtain the object reference of a reusable table view cell object instantiated under the identifier
        // TableViewCellReuseID, which was specified in the storyboard
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("DriverMenuItemCell") as UITableViewCell!
        
        // Obtain the name of the row from the table view list
        let rowName: String = tableViewList[rowNumber]
        
        // Set the label text of the cell to be the row name
        cell.textLabel!.text = rowName
        
        
        return cell
    }
    
    
    //---------------------------------------------------------------
    // Prepare the Table View Cell before it is displayed to the user
    //---------------------------------------------------------------
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Set the number of lines to be displayed in each table view cell to 2
        cell.textLabel!.numberOfLines = 2
        
        // Set the text to wrap around on the next line
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        // Set the cell label text to use the System font of size 14 pts
        cell.textLabel!.font = UIFont(name: "System", size: 14.0)
        
        
        cell.textLabel!.textColor = UIColor.blueColor()
        
        
        
        cell.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        
        
        
        
        
    }
    
    
    
    /*
     --------------------------------------------
     MARK: - UITableViewDelegate Protocol Methods
     --------------------------------------------
     */
    
    // Set the height of the table view row
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 50
    }
    
    //----------------------------------------------------------------------------
    // Perform the necessary actions when the user selects a table view row (cell)
    //----------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let rowNumber = indexPath.row
        
        
        if (rowNumber == 1){
           
            print("asdf")
            delegate?.itemSelected()
            
        }
        else {
            
            let containerViewController = ContainerViewController()
            
            Animate().showViewControllerWith(containerViewController, usingAnimation: AnimationType.ANIMATE_LEFT)
        }
        
        
        
        
    }
    
    
    
}
