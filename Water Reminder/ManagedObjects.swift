//
//  ManagedObjects.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 3/23/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import Foundation
import CoreData

class Notifications: NSManagedObject {
    @NSManaged var date: Date
    @NSManaged var label: String
    @NSManaged var sound: NSNumber
}

class Collection: NSManagedObject {
    @NSManaged var amount: NSNumber
    @NSManaged var name: String
}

class Statistics: NSManagedObject {
    @NSManaged var amount: NSNumber
    @NSManaged var date: Date
}

class Settings: NSManagedObject {
    @NSManaged var activity: NSNumber
    @NSManaged var age: NSNumber
    @NSManaged var amount: NSNumber
    @NSManaged var gender: NSNumber
    @NSManaged var goal: NSNumber
    @NSManaged var name: String
    @NSManaged var pro: NSNumber
    @NSManaged var recent: NSNumber
    @NSManaged var reminders: NSNumber
    @NSManaged var sound: NSNumber
    @NSManaged var units: NSNumber
    @NSManaged var weight: NSNumber
    @NSManaged var stamp: Date
}
