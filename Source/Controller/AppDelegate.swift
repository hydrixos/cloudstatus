//
//  AppDelegate.swift
//  CloudStatus
//
//  Created by Friedrich Gräter on 31/01/16.
//  Copyright © 2016 Friedrich Gräter. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
	var statusBarItemController : StatusItemController?

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		statusBarItemController = StatusItemController()
	}
	
	@IBAction func quit(sender: AnyObject?) {
		NSApplication.sharedApplication().terminate(sender)
	}
}
