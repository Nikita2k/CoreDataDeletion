//
//  MasterViewController.swift
//  CoreDataDeletion
//
//  Created by Nikita Tuk on 04/09/15.
//  Copyright (c) 2015 Nikita Took. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var objects = [Entity]()
    let coreDataStack = CoreDataStack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteEntry:", name: "deleteObject", object: nil)
        
        loadEntities()
    }
    
    func deleteEntry(notification: NSNotification) {
        let dateOfObject = notification.object as! NSDate
        let contextToDelete = coreDataStack.childContext()
        contextToDelete.performBlock {
            [unowned self] in
            let fetch = NSFetchRequest(entityName: "Entity")
            fetch.predicate = NSPredicate(format: "dateTime = %@", dateOfObject)
            let result = contextToDelete.executeFetchRequest(fetch, error: nil) as? [Entity]
            
            if let result = result {
                result.map() {contextToDelete.deleteObject($0)}
            }
            
            contextToDelete.saveToDb({
                self.loadEntities()
                self.tableView.reloadData()
            })
        }
    }
    
    func loadEntities() {
        let fetch = NSFetchRequest(entityName: "Entity")
        var error:NSError?
        let result = coreDataStack.context.executeFetchRequest(fetch, error: &error) as? [Entity]
        
        if let result = result {
            objects = result
        }
    }

    func insertNewObject(sender: AnyObject) {
        let entityDescription = NSEntityDescription.entityForName("Entity", inManagedObjectContext: coreDataStack.context)
        let entity = Entity(entity: entityDescription!, insertIntoManagedObjectContext: coreDataStack.context)
        entity.dateTime = NSDate()
        
        coreDataStack.context.saveToDb(nil)
        objects.insert(entity, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row]
            (segue.destinationViewController as! DetailViewController).detailItem = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.dateTime.description
        return cell
    }



}

