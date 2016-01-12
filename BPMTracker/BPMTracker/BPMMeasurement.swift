//
//  BPMMeasurement.swift
//  BPMTracker
//
//  Created by Jason Ferguson on 11/28/15.
//  Copyright © 2015 Jason Ferguson. All rights reserved.
//

import Foundation

public final class BPMMeasurement: ManagedObject {
	@NSManaged public private(set) var timestamp: NSDate
	@NSManaged public private(set) var username: String
	@NSManaged public private(set) var deviceName: String
	@NSManaged public private(set) var bpm: Int16

}