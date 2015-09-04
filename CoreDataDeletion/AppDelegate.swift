//
//  AppDelegate.swift
//  CoreDataDeletion
//
//  Created by Nikita Tuk on 04/09/15.
//  Copyright (c) 2015 Nikita Took. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Sound, categories: nil))
        }
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("received local notification")
        let objectDateToDelete = notification.userInfo!["deleteObjectWithTime"] as! NSDate
        NSNotificationCenter.defaultCenter().postNotificationName("deleteObject", object: objectDateToDelete)
    }

}

