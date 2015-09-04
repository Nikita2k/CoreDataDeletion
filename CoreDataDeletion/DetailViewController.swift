//
//  DetailViewController.swift
//  CoreDataDeletion
//
//  Created by Nikita Tuk on 04/09/15.
//  Copyright (c) 2015 Nikita Took. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var detailItem: Entity? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem, let label = self.detailDescriptionLabel {
            label.text = detail.dateTime.description
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "configureView")
        self.navigationItem.rightBarButtonItem = reloadButton
        
        self.configureView()
    }

    @IBAction func sendLocalPush(sender: AnyObject) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate().dateByAddingTimeInterval(1)
        localNotification.alertBody = "Reload data!"
        localNotification.userInfo = ["deleteObjectWithTime": detailItem!.dateTime]
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}

